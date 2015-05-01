//
//  SanityChecker.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "SanityChecker.h"
#import "ConsoleToolExecutor.h"
#import "Constants.h"
#import "Settings.h"

@interface SanityChecker ()

@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) ConsoleToolExecutor *executor;
@property (nonatomic, strong) NSString *gitLaunchPath;
@property (nonatomic, strong) NSString *gitBranchNameInAppPathURL;
@property (nonatomic, strong) NSString *gitBranchNameInScriptsPathURL;
@property (nonatomic, strong) NSString *gemLaunchPath;
@property (nonatomic, strong) NSString *frankCucumberGemVersion;
@property (nonatomic, strong) NSString *frankCucumberGemDirectoryName;
@property (nonatomic, strong) NSString *frankCucumberGemPath;

- (void)setupToolsPaths;
- (NSString *)gitBranchNameInDirectory:(NSString *)directory;
- (BOOL)isValidRepositoryPathURL:(NSURL *)pathURL;

- (BOOL)isValidAppPathURL;
- (BOOL)isValidScriptsPathURL;
- (BOOL)areTheSameBranchesInAppAndInScriptsPaths;
- (BOOL)isValidFrankCucumberGemVersion;

@end

@implementation SanityChecker

- (instancetype)initWithSettings:(Settings *)settings
{
    if (self = [super init])
    {
        self.settings = settings;
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
        
        // first leave the first line of the output only
        NSArray *lines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if ([lines count] < 1)
        {
            return nil;
        }

        NSArray *parts = [[lines firstObject] componentsSeparatedByString:@"..."];
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
    return [self isValidRepositoryPathURL:self.settings.appPathURL] && [self.gitBranchNameInAppPathURL length] > 0;
}

- (BOOL)isValidScriptsPathURL
{
    // there should be git branch available in that directory
    return [self isValidRepositoryPathURL:self.settings.scriptsPathURL] && [self.gitBranchNameInScriptsPathURL length] > 0;
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
    if (nil == _frankCucumberGemVersion)
    {
        NSArray *args = @[@"list", @"-l", self.frankCucumberGemName];
        int exitCode = -1;
        NSString *output = [self.executor outputOfCommand:self.gemLaunchPath inDirectory:nil withArguments:args exitCode:&exitCode];

        if (0 == exitCode && [output length] > 0)
        {
            _frankCucumberGemVersion = output;
        }
        else
        {
            _frankCucumberGemVersion = nil;
        }
    }

    return _frankCucumberGemVersion;
}

- (NSString *)frankCucumberGemDirectoryName
{
    if (nil == _frankCucumberGemDirectoryName)
    {
        NSString *gemString = self.frankCucumberGemVersion;
        if (nil != gemString)
        {
            NSArray *gemStringParts = [gemString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];

            if ([gemStringParts count] > 1)
            {
                _frankCucumberGemDirectoryName = [NSString stringWithFormat:@"%@-%@", self.frankCucumberGemName, gemStringParts[1]];
            }
        }
    }

    return _frankCucumberGemDirectoryName;
}

- (NSString *)frankCucumberGemPath
{
    if (nil == _frankCucumberGemPath)
    {
        // obtain search paths of gems
        NSArray *arguments = @[@"environment", @"gempath"];
        int exitCode = -1;
        NSString *output = [self.executor outputOfCommand:self.gemLaunchPath inDirectory:nil withArguments:arguments exitCode:&exitCode];

        // only continue with successful output and exit code
        if (nil != output && 0 == exitCode)
        {
            NSArray *paths = [output componentsSeparatedByString:@":"];
            // begin searching through paths for the paritcular directory
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
                        _frankCucumberGemPath = gemDir;
                        break;
                    }
                }
            }
        }
    }

    return _frankCucumberGemPath;
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
    self.gitBranchNameInAppPathURL = [self gitBranchNameInDirectory:[self.settings.appPathURL path]];
    self.gitBranchNameInScriptsPathURL = [self gitBranchNameInDirectory:[self.settings.scriptsPathURL path]];

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

- (NSArray *)listOfAvailablePlatforms
{
    NSString *envDir = [[self.settings.scriptsPathURL relativePath] stringByAppendingPathComponent:kFrankSkeletonEnv];

    NSMutableArray *result = [NSMutableArray new];

    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:envDir];
    for (NSString *file in enumerator)
    {
        // only include those ending with .sh
        if ([[file pathExtension] isEqualToString:@"sh"])
        {
            // cut off the extension, turn base file name into upper case
            NSString *baseName = [[file stringByDeletingPathExtension] uppercaseString];
            [result addObject:baseName];
        }
    }

    return result;
}

@end
