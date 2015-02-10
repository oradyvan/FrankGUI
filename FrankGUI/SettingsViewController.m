//
//  ViewController.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *warningLabel;
@property (nonatomic, weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic, weak) IBOutlet NSTextField *appBranchLabel;

@end


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.warningLabel.stringValue = @"WTF\nis this control\ndoing?";
    self.appBranchLabel.stringValue = @"unknown branch here!";
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
