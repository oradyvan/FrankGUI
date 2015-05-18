//
//  Settings.h
//  FrankGUI
//
//  Created by Oleksiy Radyvanyuk on 01/05/15.
//  Copyright (c) 2015 Oleksiy Radyvanyuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    UI_TAB_UNDEFINED = -1,
    UI_TAB_RUNNER,
    UI_TAB_SETTINGS
} UI_TAB_CHOICE;

@interface Settings : NSObject

@property (nonatomic, copy) NSURL *appPathURL;
@property (nonatomic, copy) NSURL *scriptsPathURL;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, assign) UI_TAB_CHOICE tabChoice;

@end
