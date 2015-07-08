//
//  SettingsViewController.swift
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 08/07/15.
//  Copyright © 2015 Oleksiy Radyvanyuk. All rights reserved.
//

import Cocoa

final class SettingsViewController: NSViewController, NSPathControlDelegate, SanityCheckerDelegate
{
    @IBOutlet private weak var warningLabel: NSTextField?
    @IBOutlet private weak var appPathControl: NSPathControl?
    @IBOutlet private weak var appBranchLabel: NSTextField?
    @IBOutlet private weak var scriptsPathControl: NSPathControl?
    @IBOutlet private weak var scriptsBranchLabel: NSTextField?
    @IBOutlet private weak var gemVersionLabel: NSTextField?
    @IBOutlet private weak var platformPopUp: NSPopUpButtonCell?

    private weak var settings: Settings?
    private weak var sanityChecker: SanityChecker?
    
    // MARK: - Actions

    @IBAction func appPathControlValueChanged(sender: AnyObject)
    {
        guard let control: NSPathControl = sender as? NSPathControl else
        {
            NSLog("This event handler is only valid for app path control")
            return
        }

        // Select that chosen component of the path.
        let pathURL: NSURL? = control.clickedPathComponentCell()?.URL
        appPathControl?.URL = pathURL

        // Store the selected path in user settings
        settings?.appPathURL = pathURL

        // Re-validate settings after the value has changed
        sanityChecker?.validate()
    }

    @IBAction func scriptsPathControlValueChanged(sender: AnyObject)
    {
        guard let control: NSPathControl = sender as? NSPathControl else
        {
            NSLog("This event handler is only valid for Frank scripts path control")
            return
        }

        // Select that chosen component of the path.
        let pathURL: NSURL? = control.clickedPathComponentCell()?.URL
        scriptsPathControl?.URL = pathURL

        // Store the selected path in user settings
        settings?.scriptsPathURL = pathURL

        // Re-validate settings after the value has changed
        sanityChecker?.validate()
    }

    @IBAction func revealGemDirectoryInFinder(sender: AnyObject)
    {
        // determine path to gem files based on current Ruby settings
        guard let path: String = sanityChecker?.frankCucumberGemPath else
        {
            NSLog("Oops, no path found to frank-cucumber gem!")
            return
        }

        let url: NSURL = NSURL.fileURLWithPath(path)
        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([url])
    }

    @IBAction func reloadSettings(sender: AnyObject)
    {
        sanityChecker?.validate()
    }

    @IBAction func platformPopUpValueChanged(sender: AnyObject)
    {
        guard let button: NSPopUpButton = sender as? NSPopUpButton else
        {
            NSLog("This event handler is only valid popup button control")
            return
        }

        let selectedPlatform: String? = button.titleOfSelectedItem
        settings?.platform = selectedPlatform
    }

    // MARK: - View lifecycle methods

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // prepare Settings object for being used
        settings = (NSApplication.sharedApplication().delegate as! AppDelegate).settings
    
        // Load app path from user settings
        if let appPathURL: NSURL? = settings?.appPathURL
        {
            appPathControl?.URL = appPathURL
        }
    
        // Load scripts path from user settings
        if let scriptsPathURL: NSURL? = settings?.scriptsPathURL
        {
            scriptsPathControl?.URL = scriptsPathURL
        }

        // prepare sanity checker for use in this view controller
        sanityChecker = (NSApplication.sharedApplication().delegate as! AppDelegate).sanityChecker
        sanityChecker?.delegate = self

        // perform initial validation of settings
        sanityChecker?.validate()
    }

    // MARK: - Helper methods

    private func setText(text: String?, inTextField textField: NSTextField?)
    {
        if text != nil
        {
            textField?.stringValue = text!
        }
        else
        {
            textField?.stringValue = ""
        }
    }

    private func warnLevel(warnLevel: SanityChecker.WarnLevel, message: String?)
    {
        setText(message, inTextField: warningLabel)

        switch (warnLevel)
        {
            case .OK:
                warningLabel?.textColor = NSColor.textColor()

            case .Issue:
                warningLabel?.textColor = NSColor(red: 0.7, green: 0.0, blue: 0.1, alpha: 1.0)
    
            case .Error:
                warningLabel?.textColor = NSColor.redColor()
        }
    }

    // MARK: - SanityCheckerDelegate methods

    internal func validatingDidStart()
    {
        // initial clean up of labels
        warnLevel(.OK, message: "Validating…")

        setText(nil, inTextField: appBranchLabel)
        setText(nil, inTextField: scriptsBranchLabel)
        setText(nil, inTextField: gemVersionLabel)
        platformPopUp?.removeAllItems()

        // use sanity checker for validating preferences
        settings?.appPathURL = appPathControl?.URL
        settings?.scriptsPathURL = scriptsPathControl?.URL
    }

    internal func validatingDidFinish()
    {
        setText(sanityChecker?.gitBranchNameInAppPathURL, inTextField: appBranchLabel)
        setText(sanityChecker?.gitBranchNameInScriptsPathURL, inTextField: scriptsBranchLabel)
        setText(sanityChecker?.frankCucumberGemVersion, inTextField: gemVersionLabel)

        if let platforms: [String] = sanityChecker?.listOfAvailablePlatforms()
        {
            platformPopUp?.addItemsWithTitles(platforms)
        }

        // Load platform value from user settings
        if let platform = settings?.platform
        {
            platformPopUp?.selectItemWithTitle(platform)
        }
    }

    internal func validatingWarnLevel(warnLevel: SanityChecker.WarnLevel, message: String)
    {
        self.warnLevel(warnLevel, message: message)
    }
}
