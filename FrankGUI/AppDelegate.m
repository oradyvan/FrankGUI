//
//  AppDelegate.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "AppDelegate.h"
#import "SanityChecker.h"
#import "Settings.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (SanityChecker *)sanityChecker
{
    if (nil == _sanityChecker)
    {
        _sanityChecker = [[SanityChecker alloc] initWithSettings:self.settings];
    }
    return _sanityChecker;
}

- (Settings *)settings
{
    if (nil == _settings)
    {
        _settings = [Settings new];
    }
    return _settings;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Set up app
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
