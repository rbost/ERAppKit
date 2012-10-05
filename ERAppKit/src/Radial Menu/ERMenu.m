//
//  ERMenu.m
//  ERAppKit
//
//  Created by Raphael Bost on 02/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERMenu.h"

#import "ERRadialMenuWindow.h"

@implementation ERMenu

+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view menuStyle:(ERMenuStyle)style
{
    ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:menu atLocation:[event locationInWindow] inView:[[view window] contentView] menuStyle:style];
    
    [menuWindow setReleasedWhenClosed:YES];
    [menuWindow makeKeyAndOrderFront:self];
    [menuWindow fadeIn:self];
}

+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view
{
    [self popUpContextMenu:menu withEvent:event forView:view menuStyle:ERDefaultMenuStyle];
}

+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view menuStyle:(ERMenuStyle)style
{
    ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:menu atLocation:point inView:view menuStyle:style];
    
    [menuWindow setReleasedWhenClosed:YES];
    [menuWindow makeKeyAndOrderFront:self];
    [menuWindow fadeIn:self];
}

+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view
{
    [self popUpContextMenu:menu atLocation:point inView:view menuStyle:ERDefaultMenuStyle];
}
@end
