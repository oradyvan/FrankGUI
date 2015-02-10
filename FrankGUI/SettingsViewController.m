//
//  ViewController.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "SanityChecker.h"

static NSString *const kAppPathURLKey     = @"AppPathURLKey";
static NSString *const kScriptsPathURLKey = @"ScriptsPathURLKey";

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *warningLabel;
@property (nonatomic, weak) IBOutlet NSPathControl *appPathControl;
@property (nonatomic, weak) IBOutlet NSTextField *appBranchLabel;
@property (nonatomic, weak) IBOutlet NSPathControl *scriptsPathControl;
@property (nonatomic, weak) IBOutlet NSTextField *scriptsBranchLabel;

@property (nonatomic, weak) SanityChecker *sanityChecker;

- (IBAction)appPathControlValueChanged:(id)sender;
- (IBAction)scriptsPathControlValueChanged:(id)sender;
- (void)validateSettings;

@end


@implementation SettingsViewController

- (void)validateSettings
{
    BOOL isReadyToRun = YES;

    self.warningLabel.stringValue = @"Validating…";
    self.appBranchLabel.stringValue = @"";
    self.scriptsBranchLabel.stringValue = @"";

    // use sanity checker for validating preferences
    NSURL *appPathURL = [self.appPathControl URL];
    if ([self.sanityChecker isValidAppPathURL:appPathURL])
    {
        self.appBranchLabel.stringValue = [self.sanityChecker gitBranchNameInAppPathURL:appPathURL];
    }
    else
    {
        isReadyToRun = NO;
        self.warningLabel.stringValue = @"Warning! Incorrect path to app sources";
    }

    NSURL *scriptsPathURL = [self.scriptsPathControl URL];
    if ([self.sanityChecker isValidAppPathURL:scriptsPathURL])
    {
        self.scriptsBranchLabel.stringValue = [self.sanityChecker gitBranchNameInAppPathURL:scriptsPathURL];
    }
    else
    {
        isReadyToRun = NO;
        self.warningLabel.stringValue = @"Warning! Incorrect path to Frank scripts";
    }

    if (isReadyToRun)
    {
        self.warningLabel.stringValue = @"Ready to run!";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load app path from user preferences
    NSURL *appPathURL = [[NSUserDefaults standardUserDefaults] URLForKey:kAppPathURLKey];
    if (nil != appPathURL)
    {
        [self.appPathControl setURL:appPathURL];
    }

    // Load scripts path from user preferences
    NSURL *scriptsPathURL = [[NSUserDefaults standardUserDefaults] URLForKey:kScriptsPathURLKey];
    if (nil != scriptsPathURL)
    {
        [self.scriptsPathControl setURL:scriptsPathURL];
    }

    // prepare sanity checker for use in this view controller
    self.sanityChecker = [(AppDelegate *)[[NSApplication sharedApplication] delegate] sanityChecker];

    // perform initial validation of settings
    [self validateSettings];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)appPathControlValueChanged:(id)sender
{
    NSPathControl *control = (NSPathControl *)sender;
    NSAssert(control == self.appPathControl, @"This event handler is only valid for app path control");

    // Select that chosen component of the path.
    NSURL *pathURL = [[self.appPathControl clickedPathComponentCell] URL];
    [self.appPathControl setURL:pathURL];

    // Store the selected path in user preferences
    [[NSUserDefaults standardUserDefaults] setURL:pathURL forKey:kAppPathURLKey];

    [self validateSettings];
}

- (IBAction)scriptsPathControlValueChanged:(id)sender
{
    NSPathControl *control = (NSPathControl *)sender;
    NSAssert(control == self.scriptsPathControl, @"This event handler is only valid for Frank scripts path control");
    
    // Select that chosen component of the path.
    NSURL *pathURL = [[self.scriptsPathControl clickedPathComponentCell] URL];
    [self.scriptsPathControl setURL:pathURL];
    
    // Store the selected path in user preferences
    [[NSUserDefaults standardUserDefaults] setURL:pathURL forKey:kScriptsPathURLKey];
    
    [self validateSettings];
}

@end
