//
//  SanityChecker.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "SanityChecker.h"
#import "ConsoleToolExecutor.h"

@interface SanityChecker ()

@property (nonatomic, strong) ConsoleToolExecutor *executor;
@property (nonatomic, strong) NSString *gitLaunchPath;
@property (nonatomic, strong) NSString *gitBranchNameInAppPathURL;
@property (nonatomic, strong) NSString *gitBranchNameInScriptsPathURL;

- (void)setupToolsPaths;
- (NSString *)gitBranchNameInDirectory:(NSString *)directory;
- (BOOL)isValidRepositoryPathURL:(NSURL *)pathURL;

@end

@implementation SanityChecker

- (instancetype)init
{
    if (self = [super init])
    {
        self.executor = [ConsoleToolExecutor new];
        [self setupToolsPaths];
    }

    return self;
}

- (void)setupToolsPaths
{
    // determine path to git tool
    self.gitLaunchPath = [self.executor pathForTool:@"git"];
}

- (NSString *)gitBranchNameInDirectory:(NSString *)directory
{
    NSArray* args = @[@"status", @"-s", @"-b", @"--porcelain"];
    int exitCode = -1;
    NSString *output = [self.executor outputOfCommand:self.gitLaunchPath inDirectory:directory withArguments:args exitCode:&exitCode];

    if (0 == exitCode && [output length] > 0)
    {
        // extract branch name that is usually in format like this:
        //
        // ## master...origin/master
        // ?? External/MKMapViewZoom/
        NSArray *parts = [output componentsSeparatedByString:@"..."];
        if ([parts count] > 0)
        {
            NSString *firstPart = [parts firstObject];
            NSArray *subParts = [firstPart componentsSeparatedByString:@" "];
            if ([subParts count] > 1)
            {
                return [subParts objectAtIndex:1];
            }
        }
    }

    return nil;
}

- (void)setAppPathURL:(NSURL *)appPathURL
{
    if (appPathURL != _appPathURL)
    {
        _appPathURL = appPathURL;
        self.gitBranchNameInAppPathURL = [self gitBranchNameInDirectory:[_appPathURL path]];
    }
}

- (void)setScriptsPathURL:(NSURL *)scriptsPathURL
{
    if (scriptsPathURL != _scriptsPathURL)
    {
        _scriptsPathURL = scriptsPathURL;
        self.gitBranchNameInScriptsPathURL = [self gitBranchNameInDirectory:[_scriptsPathURL path]];
    }
}

- (BOOL)isValidRepositoryPathURL:(NSURL *)pathURL
{
    // check that the given path points to an existing directory
    if ([pathURL isFileURL])
    {
        NSString *path = [pathURL path];
        BOOL pathIsDirectory = NO;
        BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&pathIsDirectory];
        
        return pathExists && pathIsDirectory;
    }

    return NO;
}

- (BOOL)isValidAppPathURL
{
    // there should be git branch available in that directory
    return [self isValidRepositoryPathURL:self.appPathURL ] && [self.gitBranchNameInAppPathURL length] > 0;
}

- (BOOL)isValidScriptsPathURL
{
    // there should be git branch available in that directory
    return [self isValidRepositoryPathURL:self.scriptsPathURL] && [self.gitBranchNameInScriptsPathURL length] > 0;
}

- (BOOL)areTheSameBranchesInAppAndInScriptsPaths
{
    // both branches for app and for scripts must be the same
    return [self.gitBranchNameInAppPathURL isEqualToString:self.gitBranchNameInScriptsPathURL];
}

@end
