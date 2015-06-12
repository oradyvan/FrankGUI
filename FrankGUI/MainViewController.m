//
//  MainViewController.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 18/05/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "MainViewController.h"
#import "FrankGUI-Swift.h"
#import "AppDelegate.h"

@interface MainViewController ()

@property (nonatomic, weak) Settings *settings;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // prepare Settings object for being used
    self.settings = [(AppDelegate *)[[NSApplication sharedApplication] delegate] settings];
}

- (void)viewDidAppear
{
    [super viewDidAppear];

    switch (self.settings.tabChoice) {
        case TabChoiceRunner:
            self.selectedTabViewItemIndex = 0;
            break;
            
        case TabChoiceSettings:
            self.selectedTabViewItemIndex = [self.tabViewItems count] - 1;
            break;
            
        default:
            break;
    }

    self.tabView.delegate = self;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [super tabView:tabView didSelectTabViewItem:tabViewItem];

    if (tabView == self.tabView)
    {
        NSInteger index = [tabView indexOfTabViewItem:tabViewItem];
        if (index == 0)
        {
            self.settings.tabChoice = TabChoiceRunner;
        }
        else if (index == [tabView numberOfTabViewItems] - 1)
        {
            self.settings.tabChoice = TabChoiceSettings;
        }
    }
}

@end
