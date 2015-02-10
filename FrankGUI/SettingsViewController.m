//
//  ViewController.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "SettingsViewController.h"

static NSString *const kAppPathURLKey = @"AppPathURLKey";

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *warningLabel;
@property (nonatomic, weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic, weak) IBOutlet NSTextField *appBranchLabel;

- (IBAction)pathControlValueChanged:(id)sender;

@end


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load app path from user preferences
    NSString *pathURLString = [[NSUserDefaults standardUserDefaults] stringForKey:kAppPathURLKey];
    if (nil != pathURLString)
    {
        NSURL *pathURL = [NSURL URLWithString:pathURLString];
        if (nil != pathURL)
        {
            [self.pathControl setURL:pathURL];
        }
    }

    // Do any additional setup after loading the view.
    self.warningLabel.stringValue = @"WTF\nis this control\ndoing?";
    self.appBranchLabel.stringValue = @"unknown branch here!";
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
    NSString *pathURLString = [pathURL absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:pathURLString forKey:kAppPathURLKey];
}

@end
