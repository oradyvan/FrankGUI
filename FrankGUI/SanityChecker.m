//
//  SanityChecker.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "SanityChecker.h"

@implementation SanityChecker

- (NSString *)gitBranchNameInDirectory:(NSString *)directory
{
    return nil;
}

- (BOOL)isValidAppPathURL:(NSURL *)appPathURL
{
    // check that the given path points to an existing directory
    if ([appPathURL isFileURL])
    {
        NSString *path = [appPathURL path];
        BOOL pathIsDirectory = NO;
        BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&pathIsDirectory];
        
        if (pathExists && pathIsDirectory)
        {
            return YES;
        }
    }

    return NO;
}

@end
