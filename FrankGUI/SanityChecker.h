//
//  SanityChecker.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Result of the last sanity check as a whole. The value dtermines if this is safe
 * to operate in the app. All levels except for WarnLevelError are considered safe
 * to operate.
 */
typedef enum
{
    WarnLevelOK,    // all sanity checks have passed successfully
    WarnLevelIssue, // there were some issues discovered during sanity checks
    WarnLevelError  // critical failure has occured while validating
} WarnLevel;


@protocol SanityCheckerDelegate

/**
 * Notifies delegate that validating did start.
 */
- (void)validatingDidStart;

/**
 * Notifies delegate that validating did finish. All the warn levels of validating are reported
 * via the method -validatingWarnLevel:message:
 */
- (void)validatingDidFinish;

/**
 * Notifies delegate that certain warn level was determined.
 *
 * @param warnLevel Warn level determined
 * @param message A message that corresponds to the warn level
 */
- (void)validatingWarnLevel:(WarnLevel)warnLevel message:(NSString *)message;

@end


@interface SanityChecker : NSObject

@property (nonatomic, assign) id<SanityCheckerDelegate> delegate;

@property (nonatomic, copy) NSURL *appPathURL;
@property (nonatomic, copy) NSURL *scriptsPathURL;
@property (nonatomic, readonly) NSString *gitBranchNameInAppPathURL;
@property (nonatomic, readonly) NSString *gitBranchNameInScriptsPathURL;
@property (nonatomic, readonly) NSString *frankCucumberGemName;
@property (nonatomic, readonly) NSString *frankCucumberGemVersion;
@property (nonatomic, readonly) NSString *frankCucumberGemPath;

- (void)validate;
- (NSArray *)listOfAvailablePlatforms;

@end
