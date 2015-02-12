//
//  SanityChecker.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SanityChecker : NSObject

@property (nonatomic, copy) NSURL *appPathURL;
@property (nonatomic, copy) NSURL *scriptsPathURL;
@property (nonatomic, readonly) NSString *gitBranchNameInAppPathURL;
@property (nonatomic, readonly) NSString *gitBranchNameInScriptsPathURL;

- (BOOL)isValidAppPathURL;
- (BOOL)isValidScriptsPathURL;
- (BOOL)areTheSameBranchesInAppAndInScriptsPaths;

@end
