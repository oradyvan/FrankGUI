//
//  ConsoleToolExecutor.swift
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 15/06/15.
//  Copyright © 2015 Oleksiy Radyvanyuk. All rights reserved.
//

import Foundation

@objc
final class ConsoleToolExecutor : NSObject
{
    private let shellPath: String?

    override init()
    {
        let environmentDict = NSProcessInfo.processInfo().environment
        shellPath = environmentDict["SHELL"]
    }

    /**
    * Synchronously executes shell command and returns its output as a string of text
    * @param command A full path to a shell command to be executed
    * @param directory Optional, current directory for the command
    * @param arguments Optional, an array of the command arguments
    * @param exitCode Pointer to ivar that will receive exit code of the shell command once
    * it completes
    * @return A text representing standard output of the shell command
    */
    @objc
    func outputOfCommand(command: String?,
        inDirectory directory: String?,
        withArguments arguments: [String]?,
        output: ((String, Int32) -> ()))
    {
        guard (command != nil) else { return }

        let aTask : NSTask = NSTask()
        
        let pipe : NSPipe = NSPipe()
        aTask.standardOutput = pipe
        
        if (arguments != nil)
        {
            aTask.arguments = arguments
        }

        if (directory != nil)
        {
            aTask.currentDirectoryPath = directory!
        }
        aTask.launchPath = command

        aTask.launch()
        aTask.waitUntilExit()

        let exitCode = aTask.terminationStatus

        let file : NSFileHandle = pipe.fileHandleForReading
        let data : NSData = file.readDataToEndOfFile()
        let string = NSString(data: data, encoding: NSUTF8StringEncoding) ?? ""

        output(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), exitCode)
    }

    /**
    * Helper method, removes readability handler of given instance of either NSFileHandle or NSPipe class
    * @param anObject An instance of a class that needs to have its readability handler cleared
    */
    private func clearReadabilityHandlerOf(anObject: AnyObject?)
    {
        if (anObject!.isKindOfClass(NSFileHandle))
        {
            let fileHandle: NSFileHandle = anObject as! NSFileHandle
            fileHandle.readabilityHandler = nil
        }
        else if (anObject!.isKindOfClass(NSPipe))
        {
            let pipe: NSPipe = anObject as! NSPipe
            pipe.fileHandleForReading.readabilityHandler = nil
        }
    }

    /**
    * Asynchronously executes shell command and calls provided handlers whenever the command
    * produces any output and when the task terminates
    * @param command A full path to a shell command to be executed
    * @param directory Optional, current directory for the command
    * @param arguments Optional, an array of the command arguments
    * @param readabilityHandler A block that is called whenever the shell command produces any
    * standard output
    * @param terminationHandler A block that is called whenever the shell command is terminated,
    * either successfully or by failing
    * @note The blocks are called on undetermined threads!
    */
    func asyncOutputOfCommand(command: String?,
        inDirectory directory: String?,
        withArguments arguments: [String]?,
        withReadabilityHandler readabilityHandler: ((NSFileHandle) -> ()),
        andTerminationHandler terminationHandler: ((NSTask) -> ()))
    {
        guard (command != nil) else { return }
        
        let aTask : NSTask = NSTask()
        
        let pipe : NSPipe = NSPipe()
        aTask.standardOutput = pipe
        
        let file : NSFileHandle = pipe.fileHandleForReading
        file.readabilityHandler = readabilityHandler

        if (arguments != nil)
        {
            aTask.arguments = arguments
        }
        
        if (directory != nil)
        {
            aTask.currentDirectoryPath = directory!
        }
        aTask.launchPath = command
        
        aTask.terminationHandler =
        { (task : NSTask) -> () in
            terminationHandler(task)
            
            self.clearReadabilityHandlerOf(task.standardOutput)
            self.clearReadabilityHandlerOf(task.standardError)
        }

        aTask.launch()
    }

    /**
    * Evaluates full path to a given shell tool. For example,
    * given "git" tool name may return "/usr/local/bin/git" path for it
    * depending on how the Git tool is installed on the system. The
    * method respects current user specific paths as it uses login shell
    * for evaluating tools paths.
    * @param toolName A short name (without path) of the desired tool
    * @return Full path to the desired tool or an empty string if it was not found
    */
    func pathForTool(toolName: String) -> String?
    {
        // invoke command like this:
        //
        // /bin/sh -l -c 'which <toolName>'
        //
        // so that the shell is used as login shell
        
        if toolName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        {
            let whichTool = "which \(toolName)"
            let args = ["-l", "-c", whichTool]
            var result: String? = nil
            outputOfCommand(shellPath, inDirectory: nil, withArguments: args, output: { (internalResult: String, _) -> () in
                result = internalResult
            })
            return result
        }

        return nil;
    }
}
