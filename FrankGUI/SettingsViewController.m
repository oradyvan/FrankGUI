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

static NSString *const kAppPathURLKey = @"AppPathURLKey";

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *warningLabel;
@property (nonatomic, weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic, weak) IBOutlet NSTextField *appBranchLabel;

@property (nonatomic, weak) SanityChecker *sanityChecker;

- (IBAction)pathControlValueChanged:(id)sender;
- (void)validateSettings;

@end


@implementation SettingsViewController

- (void)validateSettings
{
    self.warningLabel.stringValue = @"Validating…";
    self.appBranchLabel.stringValue = @"";

    // use sanity checker for validating preferences
    NSURL *appPathURL = [self.pathControl URL];
    if (![self.sanityChecker isValidAppPathURL:appPathURL])
    {
        self.warningLabel.stringValue = @"Warning! Incorrect path to app sources";
        return;
    }

    self.warningLabel.stringValue = @"Ready to run!";
    self.appBranchLabel.stringValue = [self.sanityChecker gitBranchNameInAppPathURL:appPathURL];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load app path from user preferences
    NSURL *pathURL = [[NSUserDefaults standardUserDefaults] URLForKey:kAppPathURLKey];
    if (nil != pathURL)
    {
        [self.pathControl setURL:pathURL];
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

- (IBAction)pathControlValueChanged:(id)sender
{
    // Select that chosen component of the path.
    NSURL *pathURL = [[self.pathControl clickedPathComponentCell] URL];
    [self.pathControl setURL:pathURL];

    // Store the selected path in user preferences
    [[NSUserDefaults standardUserDefaults] setURL:pathURL forKey:kAppPathURLKey];

    [self validateSettings];
}

@end
