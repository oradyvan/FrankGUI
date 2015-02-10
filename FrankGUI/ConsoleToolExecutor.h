//
//  ConsoleToolExecutor.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConsoleToolExecutor : NSObject

- (NSString *)outputOfCommand:(NSString *)command inDirectory:(NSString *)directory withArguments:(NSArray *)arguments exitCode:(int *)exitCode;
- (NSString *)pathForTool:(NSString *)toolName;

@end
