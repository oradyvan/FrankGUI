//
//  ConsoleToolExecutor.m
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import "ConsoleToolExecutor.h"


@interface ConsoleToolExecutor ()

@property (nonatomic, strong) NSString *shellPath; // path to user's shell

@end


@implementation ConsoleToolExecutor

- (instancetype)init
{
    if (self = [super init])
    {
        NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
        self.shellPath = [environmentDict objectForKey:@"SHELL"];
    }
    return self;
}

- (NSString *)outputOfCommand:(NSString *)command
                  inDirectory:(NSString *)directory
                withArguments:(NSArray *)arguments
                     exitCode:(int *)exitCode
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


/**
 * Helper method, removes readability handler of given instance of either NSFileHandle or NSPipe class
 * @param anObject An instance of a class that needs to have its readability handler cleared
 */
- (void)clearReadabilityHandlerOf:(id)anObject
{
    if ([anObject isKindOfClass:[NSFileHandle class]])
    {
        NSFileHandle *fileHandle = anObject;
        fileHandle.readabilityHandler = nil;
    }
    else if ([anObject isKindOfClass:[NSPipe class]])
    {
        NSPipe *pipe = anObject;
        [pipe fileHandleForReading].readabilityHandler = nil;
    }
}


- (void)asyncOutputOfCommand:(NSString *)command
                 inDirectory:(NSString *)directory
               withArguments:(NSArray *)arguments
      withReadabilityHandler:(ReadabilityHandlerBlock)readabilityHandler
       andTerminationHandler:(TerminationHandlerBlock)terminationHandler
{
    NSTask *aTask = [[NSTask alloc] init];
    
    NSPipe *pipe = [NSPipe pipe];
    [aTask setStandardOutput:pipe];

    if (readabilityHandler)
    {
        NSFileHandle *file = [pipe fileHandleForReading];
        file.readabilityHandler = readabilityHandler;
    }

    if (nil != arguments)
    {
        [aTask setArguments:arguments];
    }
    
    if (nil != directory)
    {
        [aTask setCurrentDirectoryPath:directory];
    }
    
    [aTask setLaunchPath:command];

    aTask.terminationHandler = ^(NSTask *task)
    {
        if (terminationHandler)
        {
            terminationHandler(task);
        }

        [self clearReadabilityHandlerOf:task.standardOutput];
        [self clearReadabilityHandlerOf:task.standardError];
    };
    
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
    }
}

- (NSString *)pathForTool:(NSString *)toolName
{
    // invoke command like this:
    //
    // /bin/sh -l -c 'which <toolName>'
    //
    // so that the shell is used as login shell

    if ([toolName length] > 0)
    {
        NSString *whichTool = [NSString stringWithFormat:@"which %@", toolName];
        NSArray *args = @[@"-l", @"-c", whichTool];
        return [self outputOfCommand:self.shellPath inDirectory:nil withArguments:args exitCode:NULL];
    }
    return nil;
}

@end
