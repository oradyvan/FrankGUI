//
//  MainViewController.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 18/05/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "MainViewController.h"
#import "Settings.h"
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
        case UI_TAB_RUNNER:
            self.selectedTabViewItemIndex = 0;
            break;
            
        case UI_TAB_SETTINGS:
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
            self.settings.tabChoice = UI_TAB_RUNNER;
        }
        else if (index == [tabView numberOfTabViewItems] - 1)
        {
            self.settings.tabChoice = UI_TAB_SETTINGS;
        }
    }
}

@end
