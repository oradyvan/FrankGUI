//
//  Settings.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 01/05/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "Settings.h"

static NSString *const kAppPathURLKey     = @"AppPathURLKey";
static NSString *const kScriptsPathURLKey = @"ScriptsPathURLKey";
static NSString *const kPlatformKey       = @"PlatformKey";

@implementation Settings
{
@protected
    NSURL *_appPathURL;
    NSURL *_scriptsPathURL;
    NSString *_platform;
}

- (NSURL *)appPathURL
{
    if (nil == _appPathURL)
    {
        // Attempt to read the value from user preferences
        _appPathURL = [[NSUserDefaults standardUserDefaults] URLForKey:kAppPathURLKey];
    }
    return _appPathURL;
}

- (void)setAppPathURL:(NSURL *)appPathURL
{
    if (_appPathURL != appPathURL)
    {
        _appPathURL = appPathURL;
        if (nil != _appPathURL)
        {
            // Store the selected path in user preferences
            [[NSUserDefaults standardUserDefaults] setURL:_appPathURL forKey:kAppPathURLKey];
        }
        else
        {
            // Remove path from user preferences
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAppPathURLKey];
        }
    }
}

- (NSURL *)scriptsPathURL
{
    if (nil == _scriptsPathURL)
    {
        // Attempt to read the value from user preferences
        _scriptsPathURL = [[NSUserDefaults standardUserDefaults] URLForKey:kScriptsPathURLKey];
    }
    return _scriptsPathURL;
}

- (void)setScriptsPathURL:(NSURL *)scriptsPathURL
{
    if (_scriptsPathURL != scriptsPathURL)
    {
        _scriptsPathURL = scriptsPathURL;
        if (nil != _scriptsPathURL)
        {
            // Store the selected path in user preferences
            [[NSUserDefaults standardUserDefaults] setURL:_scriptsPathURL forKey:kScriptsPathURLKey];
        }
        else
        {
            // Remove path from user preferences
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kScriptsPathURLKey];
        }
    }
}

- (NSString *)platform
{
    if (nil == _platform)
    {
        // Attempt to read the value from user preferences
        _platform = [[NSUserDefaults standardUserDefaults] stringForKey:kPlatformKey];
    }
    return _platform;
}

- (void)setPlatform:(NSString *)platform
{
    if (_platform != platform)
    {
        _platform = platform;
        if (nil != _platform)
        {
            // Store the selected path in user preferences
            [[NSUserDefaults standardUserDefaults] setObject:_platform forKey:kPlatformKey];
        }
        else
        {
            // Remove path from user preferences
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPlatformKey];
        }
    }
}

@end
