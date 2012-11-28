//
//  ERPaletteOpenPopup.m
//  ERAppKit
//
//  Created by Raphael Bost on 24/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteOpenPopup.h"

#import <ERAppKit/ERPaletteOpenPopupContentView.h>
#import <ERAppKit/ERPaletteOpenButton.h>

@implementation ERPaletteOpenPopup

+ (void)popupWithOrientation:(ERPalettePopupOrientation)orientation palettePanel:(ERPalettePanel *)palette atLocation:(NSPoint)screenLocation
{
    ERPaletteOpenPopup *popup = [[[self class] alloc] initWithOrientation:orientation palettePanel:palette atLocation:screenLocation];
    
    [popup makeKeyAndOrderFront:nil];
}

- (id)initWithOrientation:(ERPalettePopupOrientation)orientation palettePanel:(ERPalettePanel *)palette atLocation:(NSPoint)screenLocation
{
    NSSize popupSize;
    
    if (orientation == ERPaletteHorizontalOrientation) {
        popupSize = NSMakeSize(90, [ERPalettePanel tabWidth]-8.);
    }else{
        popupSize = NSMakeSize([ERPalettePanel tabWidth]-8., 90);
    }
    
    NSRect frame;
    frame.origin = screenLocation;
    frame.size = popupSize;
    frame.origin.x -= popupSize.width/2.;
    frame.origin.y -= popupSize.height/2.;
    
    self = [self initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    
    
    frame.origin = NSZeroPoint;
    ERPaletteOpenPopupContentView *contentView = [[ERPaletteOpenPopupContentView alloc] initWithFrame:frame];
    [self setContentView:contentView]; [contentView release];
    
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setAnimationBehavior:NSWindowAnimationBehaviorAlertPanel];
    [self setLevel:NSPopUpMenuWindowLevel];
    
    [self setReleasedWhenClosed:YES];
    
    ERPaletteOpenButton *button1 = [[ERPaletteOpenButton alloc] initWithFrame:NSMakeRect(0, 0, 30, [ERPalettePanel tabWidth]-8.)];
    ERPaletteOpenButton *button2 = [[ERPaletteOpenButton alloc] initWithFrame:NSMakeRect(60, 0, 30, [ERPalettePanel tabWidth]-8.)];

    if (orientation == ERPaletteHorizontalOrientation) {
        button1 = [[ERPaletteOpenButton alloc] initWithFrame:NSMakeRect(0, 0, 30, [ERPalettePanel tabWidth]-8.)]; [button1 setOrientation:ERPalettePanelPositionLeft];
        [button1 setTarget:palette]; [button1 setAction:@selector(openLeft:)];
        button2 = [[ERPaletteOpenButton alloc] initWithFrame:NSMakeRect(60, 0, 30, [ERPalettePanel tabWidth]-8.)]; [button2 setOrientation:ERPalettePanelPositionRight];
        [button2 setTarget:palette]; [button2 setAction:@selector(openRight:)];
    }else{
        button1 = [[ERPaletteOpenButton alloc] initWithFrame:NSMakeRect(0, 0, 30, [ERPalettePanel tabWidth]-8.)];[button1 setOrientation:ERPalettePanelPositionUp];
        [button1 setTarget:palette]; [button1 setAction:@selector(openUp:)];
        
        button2 = [[ERPaletteOpenButton alloc] initWithFrame:NSMakeRect(0, 59, 30, [ERPalettePanel tabWidth]-8.)]; [button2 setOrientation:ERPalettePanelPositionDown];
        [button2 setTarget:palette]; [button2 setAction:@selector(openDown:)];
    }

    
    [[self contentView] addSubview:button1]; [button1 release];
    [[self contentView] addSubview:button2]; [button2 release];
    
    return self;
}

- (BOOL)canBecomeKeyWindow
{
    // we have to override this method as the implementation of NSWindow return NO when the window has NSBorderlessWindowMask
    return YES;
}
- (void)resignKeyWindow
{
    [super resignMainWindow];
    [self close];
}
@end
