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

- (NSString *)gitBranchNameInAppPathURL
{
    return [self gitBranchNameInDirectory:[self.appPathURL path]];
}

- (NSString *)gitBranchNameInScriptsPathURL
{
    return [self gitBranchNameInDirectory:[self.scriptsPathURL path]];
}

- (BOOL)isValidRepositoryPathURL:(NSURL *)pathURL
{
    // check that the given path points to an existing directory
    if ([pathURL isFileURL])
    {
        NSString *path = [pathURL path];
        BOOL pathIsDirectory = NO;
        BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&pathIsDirectory];
        
        if (pathExists && pathIsDirectory)
        {
            // there should be git branch available in that directory
            NSString *branchName = [self gitBranchNameInDirectory:path];
            return [branchName length] > 0;
        }
    }
    
    return NO;
}

- (BOOL)isValidAppPathURL
{
    return [self isValidRepositoryPathURL:self.appPathURL];
}

- (BOOL)isValidScriptsPathURL
{
    return [self isValidRepositoryPathURL:self.scriptsPathURL];
}

@end
