//
//  ERAppDelegate.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *menu;
@property (assign) IBOutlet NSSlider *menuRadiusSlider;
@property (assign) IBOutlet NSSlider *centralRadiusSlider;
@property (assign) IBOutlet NSSlider *delaySlider;
@property (assign) IBOutlet NSTextField *menuRadiusField;
@property (assign) IBOutlet NSTextField *centralRadiusField;
@property (assign) IBOutlet NSTextField *delayField;

- (void)showDummyMenu:(NSEvent *)event;
@end
