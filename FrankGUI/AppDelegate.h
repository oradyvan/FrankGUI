//
//  AppDelegate.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 10/02/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SanityChecker;
@class Settings;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) SanityChecker *sanityChecker;

@end
