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
    [delaySlider setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
    [delayField setFloatValue:[ERMenu mouseOverMenuOpeningInterval]*10];
    [centralRadiusSlider setFloatValue:[ERMenu centralButtonRadius]];
    [centralRadiusField setFloatValue:[ERMenu centralButtonRadius]];
    [menuRadiusField setFloatValue:[ERMenu menuRadius]];
    [menuRadiusSlider setFloatValue:[ERMenu menuRadius]];

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
    [ERMenu setFillCentralMenuItem:[sender state]];
}
@end
