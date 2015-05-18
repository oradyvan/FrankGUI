//
//  FrankGUITests.m
//  FrankGUITests
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "ConsoleToolExecutor.h"

@interface FrankGUITests : XCTestCase

@end

@implementation FrankGUITests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testToolPaths
{
    ConsoleToolExecutor *executor = [[ConsoleToolExecutor alloc] init];
    NSString *path = [executor pathForTool:@"cp"];
    XCTAssertEqualObjects(path, @"/bin/cp", "Should resolve correct path for 'cp' tool");

    path = [executor pathForTool:@"git"];
    XCTAssertTrue([path length] > 0, @"Should have found Git tool installed on the host");

    path = [executor pathForTool:@"mumbojumbo"];
    XCTAssertTrue([path length] == 0, @"Should not find path to non-existing tool");
}

- (void)testSyncCommandExecuting
{
    ConsoleToolExecutor *executor = [[ConsoleToolExecutor alloc] init];
    NSString *gitPath = [executor pathForTool:@"git"];

    int exitCode = 0;
    NSString *result = [executor outputOfCommand:gitPath inDirectory:nil withArguments:@[@"version"] exitCode:&exitCode];
    XCTAssertTrue([result hasPrefix:@"git version "], @"Should report on Git version properly");
    XCTAssertEqual(exitCode, 0, @"Should execute the command successfully");

    result = [executor outputOfCommand:gitPath inDirectory:nil withArguments:@[@"mumbojumbo"] exitCode:&exitCode];
    XCTAssertTrue([result length] == 0, @"Should return empty string");
    XCTAssertNotEqual(exitCode, 0, @"Should fail executing the command");
}

- (void)testAsyncCommandSuccessfulExecuting
{
    ConsoleToolExecutor *executor = [[ConsoleToolExecutor alloc] init];
    NSString *shPath = [executor pathForTool:@"sh"];

    dispatch_semaphore_t sema = dispatch_semaphore_create(0L);
    __block int exitCode = 0;
    __block NSInteger readabilityBlockCalls = 0;
    NSMutableString *output = [NSMutableString new];

    [executor asyncOutputOfCommand:shPath
                       inDirectory:nil
                     withArguments:@[@"-c", @"echo Line1 && sleep 0.1 && echo Line2 && sleep 0.1 && echo Line3"]
            withReadabilityHandler:^(NSFileHandle *fileHandle)
            {
                readabilityBlockCalls++;
                NSData *data = [fileHandle availableData];
                if (nil != data)
                {
                    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [output appendString:string];
                }
            }
             andTerminationHandler:^(NSTask *task)
            {
                exitCode = [task terminationStatus];
                dispatch_semaphore_signal(sema);
            }];

    // wait until the asynchronous task completed
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    XCTAssertEqualObjects(output, @"Line1\nLine2\nLine3\n", @"Should capture all the output");
    XCTAssertEqual(exitCode, 0, @"Should execute the command successfully");
    XCTAssertEqual(readabilityBlockCalls, 3, @"Should call readability block exactly 3 times");

}

- (void)testAsyncCommandFailedExecuting
{
    ConsoleToolExecutor *executor = [[ConsoleToolExecutor alloc] init];
    // true command is always successful but it does not produce any output
    NSString *truePath = [executor pathForTool:@"true"];

    dispatch_semaphore_t sema = dispatch_semaphore_create(0L);
    __block int exitCode = -1;
    __block NSInteger readabilityBlockCalls = 0;
    NSMutableString *output = [NSMutableString new];

    [executor asyncOutputOfCommand:truePath
                       inDirectory:nil
                     withArguments:nil
            withReadabilityHandler:^(NSFileHandle *fileHandle)
            {
                readabilityBlockCalls++;
            }
             andTerminationHandler:^(NSTask *task)
            {
                exitCode = [task terminationStatus];
                dispatch_semaphore_signal(sema);
            }];
    
    // wait until the asynchronous task completed
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    XCTAssertEqualObjects(output, @"");
    XCTAssertEqual(exitCode, 0, @"Should execute the command successfully");
    XCTAssertEqual(readabilityBlockCalls, 0, @"Should NOT call readability block at all");
}

@end
