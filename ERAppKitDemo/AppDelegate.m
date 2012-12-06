//
//  ERAppDelegate.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "AppDelegate.h"

#import <ERAppKit/ERMenu.h>

@implementation AppDelegate

@synthesize window, menu, delaySlider, delayField, menuRadiusField, menuRadiusSlider, centralRadiusField, centralRadiusSlider;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [ERMenu setMouseOverMenuOpeningInterval:40];
    [ERMenu setCentralButtonRadius:25.];
    [ERMenu setMenuRadius:90.];

    [ERMenu setHUDStyleForRadialMenus];    
    
    [delaySlider setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
    [delayField setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
    [centralRadiusSlider setFloatValue:[ERMenu centralButtonRadius]];
    [centralRadiusField setFloatValue:[ERMenu centralButtonRadius]];
    [menuRadiusField setFloatValue:[ERMenu menuRadius]];
    [menuRadiusSlider setFloatValue:[ERMenu menuRadius]];
    
    // for the palettes tests
    ERPaletteTabView *upTabs = [[self paletteHolder] addTabViewWithPosition:ERPalettePanelPositionUp];
    ERPaletteTabView *leftTabs = [[self paletteHolder] addTabViewWithPosition:ERPalettePanelPositionLeft];
    ERPaletteTabView *rightTabs = [[self paletteHolder] addTabViewWithPosition:ERPalettePanelPositionRight];
    ERPaletteTabView *downTabs = [[self paletteHolder] addTabViewWithPosition:ERPalettePanelPositionDown];

    [upTabs setAutoresizingMask:(NSViewWidthSizable|NSViewMinYMargin)];
    [leftTabs setAutoresizingMask:(NSViewHeightSizable|NSViewMaxXMargin)];
    [rightTabs setAutoresizingMask:(NSViewHeightSizable|NSViewMinXMargin)];
    [downTabs setAutoresizingMask:(NSViewWidthSizable|NSViewMaxYMargin|NSViewMaxXMargin)];
   
    
    [upTabs addPaletteWithContentView:[self paletteContent1] icon:[NSImage imageNamed:@"tool-arrow"] title:@"Content 1"];
    [leftTabs addPaletteWithContentView:[self paletteContent2] icon:[NSImage imageNamed:@"tool-bezier"] title:@"Content 2"];
    [rightTabs addPaletteWithContentView:[self paletteContent3] icon:[NSImage imageNamed:@"tool-text"] title:@"Content 3"];
    [downTabs addPaletteWithContentView:[self paletteContent4] icon:[NSImage imageNamed:@"tool-oval"] title:@"Content 4"];
    [upTabs addPaletteWithContentView:[self paletteContent5] icon:[NSImage imageNamed:@"tool-rectangle"] title:@"Content 5"];
    [downTabs addPaletteWithContentView:[self paletteContent6] icon:[NSImage imageNamed:@"tool-zoom"] title:@"Content 6"];
}

- (void)showDummyMenu:(NSEvent *)event
{
  
}

- (IBAction)takeMouseOverDelayFrom:(id)sender
{
    [ERMenu setMouseOverMenuOpeningInterval:[sender floatValue]/10.];
    [delaySlider setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
    [delayField setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
}

- (IBAction)takeCentralButtonRadiusFrom:(id)sender
{
    [ERMenu setCentralButtonRadius:[sender floatValue]];
    [centralRadiusSlider setFloatValue:[ERMenu centralButtonRadius]];
    [centralRadiusField setFloatValue:[ERMenu centralButtonRadius]];
}

- (IBAction)takeMenuRadiusFrom:(id)sender
{
    [ERMenu setMenuRadius:[sender floatValue]];
    [menuRadiusField setFloatValue:[ERMenu menuRadius]];
    [menuRadiusSlider setFloatValue:[ERMenu menuRadius]];
}

- (IBAction)takeFillCentralMenuItemFrom:(id)sender
{
    [ERMenu setFillCentralMenuItem:[(NSButton *)sender state]];
}
@end
