//
//  ConsoleToolExecutor.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConsoleToolExecutor : NSObject

- (NSString *)outputOfCommand:(NSString *)command
                  inDirectory:(NSString *)directory
                withArguments:(NSArray *)arguments
                     exitCode:(int *)exitCode;

- (void)asyncOutputOfCommand:(NSString *)command
                 inDirectory:(NSString *)directory
               withArguments:(NSArray *)arguments
                      target:(id)target
       dataAvailableSelector:(SEL)dataAvailableSelector
      taskTerminatedSelector:(SEL)taskTerminatedSelector;

- (NSString *)pathForTool:(NSString *)toolName;

@end
