//
//  ERAppDelegate.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "AppDelegate.h"

#import <ERAppKit/ERMenu.h>
#import <ERAppKit/ERPalettePanel.h>

@implementation AppDelegate

@synthesize window, menu, delaySlider, delayField, menuRadiusField, menuRadiusSlider, centralRadiusField, centralRadiusSlider;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [ERMenu setMouseOverMenuOpeningInterval:40];
    [ERMenu setCentralButtonRadius:25.];
    [ERMenu setMenuRadius:90.];
    
    [delaySlider setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
    [delayField setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
    [centralRadiusSlider setFloatValue:[ERMenu centralButtonRadius]];
    [centralRadiusField setFloatValue:[ERMenu centralButtonRadius]];
    [menuRadiusField setFloatValue:[ERMenu menuRadius]];
    [menuRadiusSlider setFloatValue:[ERMenu menuRadius]];

    
    // for the palettes tests
    [[self paletteHolder] addPaletteWithContentView:[self paletteContent1] atPosition:ERPalettePanelPositionLeft];
    [[self paletteHolder] addPaletteWithContentView:[self paletteContent2] atPosition:ERPalettePanelPositionUp];
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
