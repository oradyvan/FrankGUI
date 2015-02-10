//
//  SanityChecker.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SanityChecker : NSObject

- (BOOL)isValidAppPathURL:(NSURL *)appPathURL;
- (BOOL)isValidScriptsPathURL:(NSURL *)scriptsPathURL;
- (NSString *)gitBranchNameInAppPathURL:(NSURL *)appPathURL;

@end
