//
//  ConsoleToolExecutor.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "ConsoleToolExecutor.h"

@implementation ConsoleToolExecutor

- (NSString *)outputOfCommand:(NSString *)command inDirectory:(NSString *)directory withArguments:(NSArray *)arguments exitCode:(int *)exitCode
{
    NSTask *aTask = [[NSTask alloc] init];
    
    NSPipe *pipe = [NSPipe pipe];
    [aTask setStandardOutput:pipe];
    
    [aTask setArguments:arguments];
    if (nil != directory)
    {
        [aTask setCurrentDirectoryPath:directory];
    }
    [aTask setLaunchPath:command];
    
    @try
    {
        [aTask launch];
    }
    @catch (NSException *exception)
    {
        NSLog(@"EXCEPTION: %@\nlaunch path = %@\ndirectory = %@\narguments = %@", exception, command, directory, arguments);
    }
    @finally
    {
        [aTask waitUntilExit];
        if (exitCode)
        {
            *exitCode = [aTask terminationStatus];
        }
    }
    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:[NSString defaultCStringEncoding]];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return string;
}

- (NSString *)pathForTool:(NSString *)toolName
{
    if ([toolName length] > 0)
    {
        return [self outputOfCommand:@"/usr/bin/which" inDirectory:nil withArguments:@[toolName] exitCode:NULL];
    }
    return nil;
}

@end
