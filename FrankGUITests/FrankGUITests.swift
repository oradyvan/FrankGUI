//
//  FrankGUITests.swift
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 15/06/15.
//  Copyright © 2015 Oleksiy Radyvanyuk. All rights reserved.
//

import XCTest

class FrankGUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testToolPaths(){
        
        let executor = ConsoleToolExecutor()
        let pathCp = executor.pathForTool("cp")!

        XCTAssertEqual(pathCp, "/bin/cp", "Should resolve correct path for 'cp' tool")

        let pathGit = executor.pathForTool("git")!
        XCTAssertFalse(pathGit.isEmpty, "Should have found Git tool installed on the host")

        let pathJunk = executor.pathForTool("mumbojumbo")!
        XCTAssertTrue(pathJunk.isEmpty, "Should not find path to non-existing tool")
    }
    
    func testAsyncCommandSuccessfulExecuting()
    {
        let executor = ConsoleToolExecutor()
        let shPath = executor.pathForTool("sh")

        let sema: dispatch_semaphore_t = dispatch_semaphore_create(0)

        var readabilityBlockCalls = 0
        var exitCode: Int32 = 0
        let output: NSMutableString = NSMutableString()

        executor.asyncOutputOfCommand(shPath,
            inDirectory: nil,
            withArguments: ["-c", "echo Line1 && sleep 0.1 && echo Line2 && sleep 0.1 && echo Line3"],
            withReadabilityHandler:
            { (fileHandle : NSFileHandle) -> () in
                readabilityBlockCalls++
                if let data: NSData = fileHandle.availableData
                {
                    let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                    output.appendString(string as! String)
                }
            },
            andTerminationHandler:
            { (task: NSTask) -> () in
                exitCode = task.terminationStatus
                dispatch_semaphore_signal(sema)
            }
        )

        // wait until the asynchronous task completed
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)

        XCTAssertEqual(output, "Line1\nLine2\nLine3\n", "Should capture all the output")
        XCTAssertEqual(exitCode, 0, "Should execute the command successfully")
        XCTAssertEqual(readabilityBlockCalls, 3, "Should call readability block exactly 3 times")
    }

    func testAsyncCommandFailedExecuting()
    {
        let executor = ConsoleToolExecutor()
        let truePath = executor.pathForTool("true")

        let sema: dispatch_semaphore_t = dispatch_semaphore_create(0)
        var readabilityBlockCalls = 0
        var exitCode: Int32 = 0
        let output: NSMutableString = NSMutableString()

        executor.asyncOutputOfCommand(truePath,
            inDirectory: nil,
            withArguments: nil,
            withReadabilityHandler:
            { (_) -> () in
                readabilityBlockCalls++
            },
            andTerminationHandler:
            { (task: NSTask) -> () in
                exitCode = task.terminationStatus
                dispatch_semaphore_signal(sema)
            }
        )

        // wait until the asynchronous task completed
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
        
        XCTAssertEqual(output, "")
        XCTAssertEqual(exitCode, 0, "Should execute the command successfully")
        XCTAssertEqual(readabilityBlockCalls, 0, "Should NOT call readability block at all")
    }
}
