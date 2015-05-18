//
//  ConsoleToolExecutor.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A block that is called by NSTask every time there is an output to standard output is available
 * @param fileHandle A file handle corresponding to the standard output of a task. The block
 * can access the output via calling <tt>-[NSFileHandle availableData]</tt> method
 */
typedef void (^ReadabilityHandlerBlock)(NSFileHandle *);

/**
 * A block that is called when NSTask has completed (either successful or failed) and
 * it is about to be destroyed
 * @param task A task that has completed
 */
typedef void (^TerminationHandlerBlock)(NSTask *);

@interface ConsoleToolExecutor : NSObject

/**
 * Synchronously executes shell command and returns its output as a string of text
 * @param command A full path to a shell command to be executed
 * @param directory Optional, current directory for the command
 * @param arguments Optional, an array of the command arguments
 * @param exitCode Pointer to ivar that will receive exit code of the shell command once
 * it completes
 * @return A text representing standard output of the shell command
 */
- (NSString *)outputOfCommand:(NSString *)command
                  inDirectory:(NSString *)directory
                withArguments:(NSArray *)arguments
                     exitCode:(int *)exitCode;

/**
 * Asynchronously executes shell command and calls provided handlers whenever the command
 * produces any output and when the task terminates
 * @param command A full path to a shell command to be executed
 * @param directory Optional, current directory for the command
 * @param arguments Optional, an array of the command arguments
 * @param readabilityHandler A block that is called whenever the shell command produces any
 * standard output
 * @param terminationHandler A block that is called whenever the shell command is terminated,
 * either successfully or by failing
 * @note The blocks are called on undetermined threads!
 */
- (void)asyncOutputOfCommand:(NSString *)command
                 inDirectory:(NSString *)directory
               withArguments:(NSArray *)arguments
      withReadabilityHandler:(ReadabilityHandlerBlock)readabilityHandler
       andTerminationHandler:(TerminationHandlerBlock)terminationHandler;

/**
 * Evaluates full path to a given shell tool. For example,
 * given "git" tool name may return "/usr/local/bin/git" path for it
 * depending on how the Git tool is installed on the system. The
 * method respects current user specific paths as it uses login shell
 * for evaluating tools paths.
 * @param toolName A short name (without path) of the desired tool
 * @return Full path to the desired tool or an empty string if it was not found
 */
- (NSString *)pathForTool:(NSString *)toolName;

@end
