//
//  SanityChecker.swift
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 16/06/15.
//  Copyright © 2015 Oleksiy Radyvanyuk. All rights reserved.
//

import Foundation

@objc
protocol SanityCheckerDelegate
{
    /**
    * Notifies delegate that validating did start.
    */
    func validatingDidStart()

    /**
    * Notifies delegate that validating did finish. All the warn levels of validating are reported
    * via the method -validatingWarnLevel:message:
    */
    func validatingDidFinish()

    /**
    * Notifies delegate that certain warn level was determined.
    *
    * @param warnLevel Warn level determined
    * @param message A message that corresponds to the warn level
    */
    func validatingWarnLevel(warnLevel: SanityChecker.WarnLevel, message: String)
}

final class SanityChecker : NSObject
{
    /**
    * Result of the last sanity check as a whole. The value dtermines if this is safe
    * to operate in the app. All levels except for WarnLevelError are considered safe
    * to operate.
    */
    @objc enum WarnLevel: Int
    {
        case OK    // all sanity checks have passed successfully
        case Issue // there were some issues discovered during sanity checks
        case Error // critical failure has occured while validating
    }

    var delegate: SanityCheckerDelegate?

    private(set) var gitBranchNameInAppPathURL: String?
    private(set) var gitBranchNameInScriptsPathURL: String?
    var frankCucumberGemName: String {
        get {
            return "ngti-frank-cucumber"
        }
    }

    private var _frankCucumberGemVersion: String?
    var frankCucumberGemVersion: String? {
        get {
            if (_frankCucumberGemVersion == nil)
            {
                let args = ["list", "-l", frankCucumberGemName]
                var exitCode: Int32 = -1
                var output: String? = nil
                executor.outputOfCommand(gemLaunchPath,
                    inDirectory: nil,
                    withArguments: args,
                    output:
                    { (internalResult: String, internalExitCode: Int32) in
                        output = internalResult
                        exitCode = internalExitCode
                    }
                )
                
                if ((exitCode == 0) && (output?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0))
                {
                    _frankCucumberGemVersion = output
                }
                else
                {
                    _frankCucumberGemVersion = nil
                }
            }
            return _frankCucumberGemVersion
        }
    }

    private var _frankCucumberGemDirectoryName: String?
    private var frankCucumberGemDirectoryName: String? {
        get {
            if (_frankCucumberGemDirectoryName == nil)
            {
                if let gemString = frankCucumberGemVersion
                {
                    let gemStringParts = gemString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "()"))

                    if (gemStringParts.count > 1)
                    {
                        _frankCucumberGemDirectoryName = "\(frankCucumberGemName)-\(gemStringParts[1])"
                    }
                }
            }
            return _frankCucumberGemDirectoryName
        }
    }
    
    private var _frankCucumberGemPath: String?
    var frankCucumberGemPath: String? {
        get {
            if (_frankCucumberGemPath == nil)
            {
                // obtain search paths of gems
                let arguments = ["environment", "gempath"]
                var exitCode: Int32 = -1
                var output: String? = nil
                executor.outputOfCommand(gemLaunchPath,
                    inDirectory: nil,
                    withArguments: arguments,
                    output:
                    { (internalResult: String, internalExitCode: Int32) in
                        output = internalResult
                        exitCode = internalExitCode
                    }
                )

                // only continue with successful output and exit code
                if ((exitCode == 0) && (output?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0))
                {
                    let paths = output!.componentsSeparatedByString(":")
                    // begin searching through paths for the paritcular directory
                    let gemDirName = frankCucumberGemDirectoryName
                    let fileMan: NSFileManager = NSFileManager.defaultManager()
                    for path: String in paths
                    {
                        // construct candidate directory of gems common base directory and particular gem name
                        let gemDir = "\(path)/gems/\(gemDirName)"
                        var isDirectory: ObjCBool = false
                        if (fileMan.fileExistsAtPath(gemDir, isDirectory:&isDirectory))
                        {
                            if (isDirectory)
                            {
                                _frankCucumberGemPath = gemDir
                                break
                            }
                        }
                    }
                }
            }
            return _frankCucumberGemPath
        }
    }

    private var settings: Settings
    private var executor: ConsoleToolExecutor

    init(settings: Settings)
    {
        self.settings = settings
        executor = ConsoleToolExecutor()

        gitBranchNameInAppPathURL = ""
        gitBranchNameInScriptsPathURL = ""

        super.init()
        setupToolsPaths()
    }

    func validate()
    {
        delegate?.validatingDidStart()
        gitBranchNameInAppPathURL = gitBranchNameInDirectory(settings.appPathURL?.path)
        gitBranchNameInScriptsPathURL = gitBranchNameInDirectory(settings.scriptsPathURL?.path)

        if (!isValidAppPathURL())
        {
            delegate?.validatingWarnLevel(.Error, message: "Error! Incorrect path to app sources")
            delegate?.validatingDidFinish()
            return
        }

        if (!isValidScriptsPathURL())
        {
            delegate?.validatingWarnLevel(.Error, message: "Error! Incorrect path to Frank scripts")
            delegate?.validatingDidFinish()
            return
        }

        // verifying correctness of "ngti-frank-cucumber" gem version
        if ((frankCucumberGemVersion != nil) && !isValidFrankCucumberGemVersion())
        {
            let message = "Error! Cannot determine version of gem '\(frankCucumberGemName)'! Make sure it is installed."
            delegate?.validatingWarnLevel(.Error, message: message)
            delegate?.validatingDidFinish()
            return
        }

        // verifying correctness of both branches
        if (!areTheSameBranchesInAppAndInScriptsPaths())
        {
            delegate?.validatingWarnLevel(.Issue, message: "Warning! App has checked out of branch different from Frank scripts branch.\nMake sure you understand what you are doing!")
            delegate?.validatingDidFinish()
            return
        }

        // if we got here, all the checks have passed
        delegate?.validatingWarnLevel(.OK, message: "Ready to run!")
        delegate?.validatingDidFinish()
    }

    func listOfAvailablePlatforms() -> [String]
    {
        guard let envDir = settings.scriptsPathURL?.relativePath?.stringByAppendingPathComponent("env") else {
            // something went wrong - no path to "env" subdirectory
            return []
        }

        var result = [String]()

        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(envDir)
        while let file = enumerator?.nextObject() as? String
        {
            // only include those ending with .sh
            if (file.pathExtension == "sh")
            {
                // cut off the extension, turn base file name into upper case
                let baseName = file.stringByDeletingPathExtension.uppercaseString
                result.append(baseName)
            }
        }

        return result
    }

    private var gitLaunchPath: String?
    private var gemLaunchPath: String?

    private func setupToolsPaths()
    {
        // determine path to git tool
        gitLaunchPath = executor.pathForTool("git")

        // determine path to gem tool
        gemLaunchPath = executor.pathForTool("gem")
    }

    private func gitBranchNameInDirectory(directory: String?) -> String?
    {
        let args = ["status", "-s", "-b", "--porcelain"]

        var exitCode: Int32 = -1
        var output: String = ""

        executor.outputOfCommand(gitLaunchPath,
            inDirectory: directory,
            withArguments: args,
            output:
            { (internalResult: String, internalExitCode: Int32) in
                output = internalResult
                exitCode = internalExitCode
            }
        )

        if (exitCode == 0) && (output.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
        {
            // extract branch name that is usually in format like this:
            //
            // ## master...origin/master
            // ?? External/MKMapViewZoom/
            
            // first leave the first line of the output only
            let lines = output.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            if (lines.count < 1)
            {
                return nil
            }
            
            let parts = lines.first?.componentsSeparatedByString("...")
            if (parts?.count > 0)
            {
                let firstPart = parts?.first
                let subParts = firstPart?.componentsSeparatedByString(" ")
                
                if (subParts?.count > 1)
                {
                    return subParts?[1]
                }
            }
        }

        return nil
    }
    
    private func isValidRepositoryPathURL(pathURL: NSURL) -> Bool
    {
        // check that the given path points to an existing directory
        if (pathURL.fileURL)
        {
            let path = pathURL.path
            var pathIsDirectory: ObjCBool = false
            let pathExists = NSFileManager.defaultManager().fileExistsAtPath(path!, isDirectory: &pathIsDirectory)
            return pathExists && pathIsDirectory
        }

        return false
    }
    
    private func isValidAppPathURL() -> Bool
    {
        // there should be git branch available in that directory
        return isValidRepositoryPathURL(settings.appPathURL!) &&
            (gitBranchNameInAppPathURL!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
    }

    private func isValidScriptsPathURL() -> Bool
    {
        // there should be git branch available in that directory
        return isValidRepositoryPathURL(settings.scriptsPathURL!) &&
            (gitBranchNameInScriptsPathURL!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
    }
    
    private func areTheSameBranchesInAppAndInScriptsPaths() -> Bool
    {
        // both branches for app and for scripts must be the same
        return gitBranchNameInAppPathURL == gitBranchNameInScriptsPathURL
    }

    private func isValidFrankCucumberGemVersion() -> Bool
    {
        // get the full name and version of the gem
        let gemString = frankCucumberGemVersion
        let gemStringParts = gemString!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "()"))

        if (gemStringParts.count != 3)
        {
            // expect gem string in format <name> (<version>)
            return false
        }

        let versionParts = gemStringParts[1].componentsSeparatedByString(".")
        if (versionParts.count != 3)
        {
            // expect version components like <major>.<minor>.<build>
            return false
        }

        // expect versions of 1.3.x
        let versionPartMajor = Int(versionParts[0])
        let versionPartMinor = Int(versionParts[1])
        if (versionPartMajor < 1) || (versionPartMinor < 3)
        {
            return false
        }

        return true
    }
}
