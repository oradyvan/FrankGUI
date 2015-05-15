//
//  RunnerViewController.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 15/05/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "RunnerViewController.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "ConsoleToolExecutor.h"

@interface RunnerViewController ()

@property (weak) IBOutlet NSScrollView *outputView;
@property (weak) IBOutlet NSButton *frankifyButton;
@property (weak) IBOutlet NSButton *runSuitesButton;

@property (nonatomic, weak) Settings *settings;

- (IBAction)onFrankify:(id)sender;

@end

@implementation RunnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // prepare Settings object for being used
    self.settings = [(AppDelegate *)[[NSApplication sharedApplication] delegate] settings];
}

- (void)enableButtons:(BOOL)enabled
{
    self.frankifyButton.enabled = enabled;
    self.runSuitesButton.enabled = enabled;
}

- (IBAction)onFrankify:(id)sender
{
    [self enableButtons:NO];

    NSTextView *textView = self.outputView.contentView.documentView;
    [textView.textStorage.mutableString setString:@""];

    NSString *script = [[self.settings.scriptsPathURL relativePath] stringByAppendingPathComponent:@"test-reads.sh"];

    ConsoleToolExecutor *executor = [[ConsoleToolExecutor alloc] init];
    [executor asyncOutputOfCommand:script
                       inDirectory:nil
                     withArguments:nil
                            target:self
             dataAvailableSelector:@selector(onFileHandleDataAvailableNotification:)
            taskTerminatedSelector:@selector(onExecutingTaskCompleted:)];
}

- (void)onFileHandleDataAvailableNotification:(NSNotification *)notification
{
    NSFileHandle *fileHandle = notification.object;
    NSData *data = fileHandle.availableData;

    if (nil != data)
    {
        // wait for possibly more output
        [fileHandle waitForDataInBackgroundAndNotify];

        // extract available data and disply in output view
        NSString *string = [[NSString alloc] initWithData:data encoding:[NSString defaultCStringEncoding]];

        NSTextView *textView = self.outputView.contentView.documentView;
        [textView.textStorage.mutableString appendString:string];
    }
}

- (void)onExecutingTaskCompleted:(NSNotification *)notification
{
    NSTask *task = notification.object;
    if (!task.isRunning)
    {
        if (0 == [task terminationStatus])
        {
            NSLog(@"Task succeeded: %@", task);
        }
        else
        {
            NSLog(@"Task failed: %@", task);
        }
        
        [self enableButtons:YES];
    }
}

@end
