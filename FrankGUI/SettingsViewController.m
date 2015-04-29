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

@interface SettingsViewController () <SanityCheckerDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *warningLabel;
@property (nonatomic, weak) IBOutlet NSPathControl *appPathControl;
@property (nonatomic, weak) IBOutlet NSTextField *appBranchLabel;
@property (nonatomic, weak) IBOutlet NSPathControl *scriptsPathControl;
@property (nonatomic, weak) IBOutlet NSTextField *scriptsBranchLabel;
@property (nonatomic, weak) IBOutlet NSTextField *gemVersionLabel;

@property (nonatomic, weak) SanityChecker *sanityChecker;

- (IBAction)appPathControlValueChanged:(id)sender;
- (IBAction)scriptsPathControlValueChanged:(id)sender;
- (void)warnLevel:(WarnLevel)warnLevel message:(NSString *)message;
- (void)setText:(NSString *)text inTextField:(NSTextField *)textField;

@end


@implementation SettingsViewController

- (void)warnLevel:(WarnLevel)warnLevel message:(NSString *)message
{
    [self setText:message inTextField:self.warningLabel];

    switch (warnLevel) {
        case WarnLevelOK:
            self.warningLabel.textColor = [NSColor textColor];
            break;

        case WarnLevelIssue:
            self.warningLabel.textColor = [NSColor colorWithRed:0.7f green:0.f blue:0.1f alpha:1.0f];
            break;
            
        case WarnLevelError:
            self.warningLabel.textColor = [NSColor redColor];
            break;

        default:
            break;
    }
}

- (void)setText:(NSString *)text inTextField:(NSTextField *)textField
{
    textField.stringValue = (nil == text) ? @"" : text;
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
    self.sanityChecker.delegate = self;

    // perform initial validation of settings
    [self.sanityChecker validate];
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

    [self.sanityChecker validate];
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
    
    [self.sanityChecker validate];
}

#pragma mark - SanityCheckerDelegate methods

- (void)validatingDidStart
{
    // initial clean up of labels
    [self warnLevel:WarnLevelOK message:@"Validating…"];
    [self setText:nil inTextField:self.appBranchLabel];
    [self setText:nil inTextField:self.scriptsBranchLabel];
    [self setText:nil inTextField:self.gemVersionLabel];

    // use sanity checker for validating preferences
    self.sanityChecker.appPathURL = [self.appPathControl URL];
    self.sanityChecker.scriptsPathURL = [self.scriptsPathControl URL];
}

- (void)validatingDidFinish
{
    [self setText:[self.sanityChecker gitBranchNameInAppPathURL] inTextField:self.appBranchLabel];
    [self setText:[self.sanityChecker gitBranchNameInScriptsPathURL] inTextField:self.scriptsBranchLabel];
    [self setText:self.sanityChecker.frankCucumberGemVersion inTextField:self.gemVersionLabel];
}

- (void)validatingWarnLevel:(WarnLevel)warnLevel message:(NSString *)message
{
    [self warnLevel:warnLevel message:message];
}

@end
