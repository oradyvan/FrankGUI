//
//  AppDelegate.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "AppDelegate.h"
#import "SanityChecker.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (SanityChecker *)sanityChecker
{
    if (nil == _sanityChecker)
    {
        _sanityChecker = [SanityChecker new];
    }
    return _sanityChecker;
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
    // Tear down app
}

@end
