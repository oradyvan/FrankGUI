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
@property (nonatomic, strong) NSString *gemLaunchPath;

- (void)setupToolsPaths;
- (NSString *)gitBranchNameInDirectory:(NSString *)directory;
- (BOOL)isValidRepositoryPathURL:(NSURL *)pathURL;

- (BOOL)isValidAppPathURL;
- (BOOL)isValidScriptsPathURL;
- (BOOL)areTheSameBranchesInAppAndInScriptsPaths;
- (BOOL)isValidFrankCucumberGemVersion;

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

    // determine path to gem tool
    self.gemLaunchPath = [self.executor pathForTool:@"gem"];
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

- (NSString *)frankCucumberGemName
{
    return @"ngti-frank-cucumber";
}

- (NSString *)frankCucumberGemVersion
{
    NSArray *args = @[@"list", @"-l", self.frankCucumberGemName];
    int exitCode = -1;
    NSString *output = [self.executor outputOfCommand:self.gemLaunchPath inDirectory:nil withArguments:args exitCode:&exitCode];

    if (0 == exitCode && [output length] > 0)
    {
        return output;
    }
    else
    {
        return nil;
    }
}

- (NSString *)frankCucumberGemDirectoryName
{
    NSString *gemString = self.frankCucumberGemVersion;
    NSArray *gemStringParts = [gemString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];

    return [NSString stringWithFormat:@"%@-%@", self.frankCucumberGemName, gemStringParts[1]];
}

- (NSString *)frankCucumberGemPath
{
    // obtain search paths of gems
    NSArray *arguments = @[@"environment", @"gempath"];
    int exitCode = -1;
    NSString *output = [self.executor outputOfCommand:self.gemLaunchPath inDirectory:nil withArguments:arguments exitCode:&exitCode];

    // on error, return nil
    if (nil == output || 0 != exitCode)
    {
        return nil;
    }

    NSArray *paths = [output componentsSeparatedByString:@":"];
    // begin searching through paths for the paritcular directory
    NSString *result = nil;
    NSString *gemDirName = self.frankCucumberGemDirectoryName;
    NSFileManager *fileMan = [NSFileManager defaultManager];
    for (NSString *path in paths)
    {
        // construct candidate directory of gems common base directory and particular gem name
        NSString *gemDir = [NSString stringWithFormat:@"%@/gems/%@", path, gemDirName];
        BOOL isDirectory = NO;
        if ([fileMan fileExistsAtPath:gemDir isDirectory:&isDirectory])
        {
            if (isDirectory)
            {
                result = gemDir;
                break;
            }
        }
    }

    return result;
}

- (BOOL)isValidFrankCucumberGemVersion
{
    // get the full name and version of the gem
    NSString *gemString = self.frankCucumberGemVersion;
    NSArray *gemStringParts = [gemString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];

    if (3 != [gemStringParts count])
    {
        // expect gem string in format <name> (<version>)
        return NO;
    }
    
    NSArray *versionParts = [gemStringParts[1] componentsSeparatedByString:@"."];
    if (3 != [versionParts count])
    {
        // expect version components like <major>.<minor>.<build>
        return NO;
    }
    
    // expect versions of 1.3.x
    if ([versionParts[0] intValue] < 1 || [versionParts[1] intValue] < 3)
    {
        return NO;
    }

    return YES;
}

- (void)validate
{
    [self.delegate validatingDidStart];

    if (![self isValidAppPathURL])
    {
        [self.delegate validatingWarnLevel:WarnLevelError message:@"Error! Incorrect path to app sources"];
        [self.delegate validatingDidFinish];
        return;
    }

    if (![self isValidScriptsPathURL])
    {
        [self.delegate validatingWarnLevel:WarnLevelError message:@"Error! Incorrect path to Frank scripts"];
        [self.delegate validatingDidFinish];
        return;
    }

    // verifying correctness of "ngti-frank-cucumber" gem version
    NSString *gemVersion = self.frankCucumberGemVersion;
    if (nil == gemVersion || ![self isValidFrankCucumberGemVersion])
    {
        NSString *message = [NSString stringWithFormat:@"Error! Cannot determine version of gem '%@'! Make sure it is installed.", self.frankCucumberGemName];
        [self.delegate validatingWarnLevel:WarnLevelError message:message];
        [self.delegate validatingDidFinish];
        return;
    }

    // verifying correctness of both branches
    if (![self areTheSameBranchesInAppAndInScriptsPaths])
    {
        [self.delegate validatingWarnLevel:WarnLevelIssue message:@"Warning! App has checked out of branch different from Frank scripts branch.\nMake sure you understand what you are doing!"];
        [self.delegate validatingDidFinish];
        return;
    }

    // if we got here, all the checks have passed
    [self.delegate validatingWarnLevel:WarnLevelOK message:@"Ready to run!"];
    [self.delegate validatingDidFinish];
}

@end
