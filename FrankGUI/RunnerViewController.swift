//
//  RunnerViewController.swift
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 08/07/15.
//  Copyright © 2015 Oleksiy Radyvanyuk. All rights reserved.
//

import Cocoa

final class RunnerViewController: NSViewController
{
    @IBOutlet private weak var outputView: NSScrollView?
    @IBOutlet private weak var frankifyButton: NSButton?
    @IBOutlet private weak var runSuitesButton: NSButton?

    private weak var settings: Settings?
    private let executor: ConsoleToolExecutor = ConsoleToolExecutor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = (NSApplication.sharedApplication().delegate as! AppDelegate).settings
    }
    
    private func enableButtons(enabled: Bool)
    {
        frankifyButton?.enabled = enabled
        runSuitesButton?.enabled = enabled
    }

    @IBAction func onFrankify(sender: AnyObject)
    {
        enableButtons(false)

        let textView: NSTextView? = outputView?.contentView.documentView as? NSTextView
        textView?.textStorage?.mutableString.setString("")

        let script: String? = settings?.scriptsPathURL?.relativePath?.stringByAppendingPathComponent("setup_frank.sh")

        executor.asyncOutputOfCommand(script,
            inDirectory: nil,
            withArguments: nil,
            withReadabilityHandler:
            { (fileHandle: NSFileHandle) -> () in
                let data = fileHandle.availableData
                self.onFileHandleDataAvailable(data)
            })
            { (task: NSTask) -> () in
                self.onExecutingTaskCompleted(task)
            }
    }
    
    private func onFileHandleDataAvailable(aData: NSData)
    {
        // extract available data and display in output view
        guard let string: NSString = NSString(data: aData, encoding: NSUTF8StringEncoding) else { return }
        NSLog("%@", string)

        dispatch_async(dispatch_get_main_queue())
        { () -> Void in
            let textView: NSTextView? = self.outputView?.contentView.documentView as? NSTextView
            textView?.textStorage?.mutableString.appendString(string as String)
        }
    }

    private func onExecutingTaskCompleted(task: NSTask)
    {
        guard !task.running else { return }

        if (task.terminationStatus == 0)
        {
            NSLog("Task succeeded: %@", task)
        }
        else
        {
            NSLog("Task failed: %@", task)
        }

        dispatch_async(dispatch_get_main_queue())
        { () -> Void in
            self.enableButtons(true)
        }
    }

}
