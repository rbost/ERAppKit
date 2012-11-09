//
//  ERAppDelegate.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERPaletteHolderView.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *menu;
@property (assign) IBOutlet NSSlider *menuRadiusSlider;
@property (assign) IBOutlet NSSlider *centralRadiusSlider;
@property (assign) IBOutlet NSSlider *delaySlider;
@property (assign) IBOutlet NSTextField *menuRadiusField;
@property (assign) IBOutlet NSTextField *centralRadiusField;
@property (assign) IBOutlet NSTextField *delayField;
@property (assign) IBOutlet NSView *paletteContent1;
@property (assign) IBOutlet NSView *paletteContent2;
@property (assign) IBOutlet NSView *paletteContent3;
@property (assign) IBOutlet NSView *paletteContent4;
@property (assign) IBOutlet NSView *paletteContent5;
@property (assign) IBOutlet NSView *paletteContent6;

@property (assign) IBOutlet ERPaletteHolderView *paletteHolder;

- (void)showDummyMenu:(NSEvent *)event;
@end
