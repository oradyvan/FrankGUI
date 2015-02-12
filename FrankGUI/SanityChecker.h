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

- (BOOL)isValidAppPathURL;
- (BOOL)isValidScriptsPathURL;
- (NSString *)gitBranchNameInAppPathURL;
- (NSString *)gitBranchNameInScriptsPathURL;

@end
