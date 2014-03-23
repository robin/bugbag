//
//  AppDelegate.h
//  bugbag
//
//  Created by Robin Lu on 3/23/14.
//  Copyright (c) 2014 Robin Lu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CBLManager;
@class CBLDatabase;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction)createDoc:(id)sender;
- (IBAction)sync:(id)sender;
@end
