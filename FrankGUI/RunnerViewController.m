//
//  RunnerViewController.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 15/05/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "RunnerViewController.h"
#import "AppDelegate.h"
#import "FrankGUI-Swift.h"
#import "ConsoleToolExecutor.h"

@interface RunnerViewController ()

@property (weak) IBOutlet NSScrollView *outputView;
@property (weak) IBOutlet NSButton *frankifyButton;
@property (weak) IBOutlet NSButton *runSuitesButton;

@property (nonatomic, weak) Settings *settings;
@property (nonatomic, strong) ConsoleToolExecutor *executor;

- (IBAction)onFrankify:(id)sender;

@end

@implementation RunnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // prepare Settings object for being used
    self.settings = [(AppDelegate *)[[NSApplication sharedApplication] delegate] settings];

    self.executor = [[ConsoleToolExecutor alloc] init];
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

    NSString *script = [[self.settings.scriptsPathURL relativePath] stringByAppendingPathComponent:@"setup_frank.sh"];

    __weak __typeof(self) weakSelf = self;

    [self.executor asyncOutputOfCommand:script
                            inDirectory:nil
                          withArguments:nil
                 withReadabilityHandler:^(NSFileHandle *fileHandle)
     {
         NSData *data = fileHandle.availableData;
         [weakSelf onFileHandleDataAvailable:data];
     }
                  andTerminationHandler:^(NSTask *task)
     {
         [weakSelf onExecutingTaskCompleted:task];
     }];
}

- (void)onFileHandleDataAvailable:(NSData *)aData
{
    if (nil != aData)
    {
        // extract available data and display in output view
        NSString *string = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", string);

        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSTextView *textView = self.outputView.contentView.documentView;
            [textView.textStorage.mutableString appendString:string];
        });
    }
}

- (void)onExecutingTaskCompleted:(NSTask *)task
{
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
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self enableButtons:YES];
        });
    }
}

@end
