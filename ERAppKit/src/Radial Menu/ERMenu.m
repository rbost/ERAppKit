//
//  ERMenu.m
//  ERAppKit
//
//  Created by Raphael Bost on 02/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERMenu.h"

#import "ERRadialMenuWindow.h"

static NSGradient *__selectedItemGradient = nil;
static NSColor *__selectedItemColor = nil;
static NSColor *__selectedItemStrokeColor = nil;
static NSGradient *__itemGradient = nil;
static NSColor *__itemColor = nil;
static NSColor *__itemStrokeColor = nil;

static NSColor *__submenuArrowColor = nil;
static NSColor *__submenuArrowSelectedColor = nil;

static NSDictionary *__menuItemTitleAttributes = nil;
static NSDictionary *__selectedMenuItemTitleAttributes = nil;

static BOOL __fillCentralMenuItem = YES;

static BOOL __openSubmenusOnMouseOver = YES;
static NSTimeInterval __mouseOverMenuOpeningInterval = 0.5f;

static CGFloat __centralButtonRadius = 30.;
static CGFloat __menuRadius = 100.;

@implementation ERMenu

+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view menuStyle:(ERMenuStyle)style
{
    ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:menu atLocation:[event locationInWindow] inView:[[view window] contentView] menuStyle:style];
    
    [menuWindow setReleasedWhenClosed:YES];
    [menuWindow makeKeyAndOrderFront:self];
    [menuWindow fadeIn:self];
}

+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view menuStyle:(ERMenuStyle)style direction:(CGFloat)direction
{
    ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:menu atLocation:[event locationInWindow] inView:[[view window] contentView] menuStyle:style direction:direction];
    
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

+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view menuStyle:(ERMenuStyle)style direction:(CGFloat)direction
{
    ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:menu atLocation:point inView:view menuStyle:style direction:direction];
    
    [menuWindow setReleasedWhenClosed:YES];
    [menuWindow makeKeyAndOrderFront:self];
    [menuWindow fadeIn:self];
}

+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view
{
    [self popUpContextMenu:menu atLocation:point inView:view menuStyle:ERDefaultMenuStyle];
}

#pragma mark Appearance Options

+ (NSGradient *)selectedItemGradient
{
    if(!__selectedItemGradient && !__selectedItemColor){ // no gradient and no color set --> the gradient is the default
        __selectedItemGradient = [[NSGradient alloc] initWithStartingColor:
                                  [NSColor colorWithCalibratedRed:.396 green:.541 blue:.941 alpha:1.]
                                                               endingColor:
                                  [NSColor colorWithCalibratedRed:.157 green:.384 blue:.929 alpha:1.]];
    }
    
    return __selectedItemGradient;
}

+ (void)setSelectedItemGradient:(NSGradient *)gradient
{
    [gradient retain];
    [__selectedItemGradient release];
    __selectedItemGradient = gradient;
    
    if(gradient){
        [self setSelectedItemColor:nil]; // put the selected item color to nil so we know we are using a gradient
    }
}

+ (NSColor *)selectedItemColor
{
    return __selectedItemColor; // --> if the selected item color is nil, you should search for the selected item gradient
}

+ (void)setSelectedItemColor:(NSColor *)color
{
    [color retain];
    [__selectedItemColor release];
    __selectedItemColor = color;
    
    if (color) {
        [self setSelectedItemGradient:nil]; // put the selected item gradient to nil so we know we are using a color
    }

}

+ (NSColor *)selectedItemStrokeColor
{
    if(!__selectedItemStrokeColor){
        __selectedItemStrokeColor = [[NSColor colorWithCalibratedRed:0.898 green:0.898 blue:0.898 alpha:1] copy];
    }
    
    return __selectedItemStrokeColor;
}

+ (void)setSelectedItemStrokeColor:(NSColor *)color
{
    [color retain];
    [__selectedItemStrokeColor release];
    __selectedItemStrokeColor = color;
}

+ (NSGradient *)itemGradient
{
    return __itemGradient;
}

+ (void)setItemGradient:(NSGradient *)gradient
{
    [gradient retain];
    [__itemGradient release];
    __itemGradient = gradient;
    
    if(gradient){
        [self setItemColor:nil]; // put the item color to nil so we know we are using a gradient
    }
}

+ (NSColor *)itemColor
{
    if(!__itemColor && !__itemGradient){
        __itemColor = [[NSColor controlBackgroundColor] copy];
    }
    
    return __itemColor;
}

+ (void)setItemColor:(NSColor *)color
{
    [color retain];
    [__itemColor release];
    __itemColor = color;
    
    if (color) {
        [self setItemGradient:nil]; // put the item gradient to nil so we know we are using a color
    }

}

+ (NSColor *)itemStrokeColor
{
    if(!__itemStrokeColor){
        __itemStrokeColor = [[NSColor colorWithCalibratedRed:0.898 green:0.898 blue:0.898 alpha:1] copy];
    }
    
    return __itemStrokeColor;
}

+ (void)setItemStrokeColor:(NSColor *)color
{
    [color retain];
    [__itemStrokeColor release];
    __itemStrokeColor = color;
}

+ (NSColor *)submenuArrowColor
{
    if(!__submenuArrowColor){
        __submenuArrowColor = [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] copy];
    }
    
    return __submenuArrowColor;
}

+ (void)setSubmenuArrowColor:(NSColor *)color
{
    [color retain];
    [__submenuArrowColor release];
    __submenuArrowColor = color;
}

+ (NSColor *)submenuArrowSelectedColor
{
    if(!__submenuArrowSelectedColor){
        __submenuArrowSelectedColor = [[NSColor whiteColor] copy];
    }
    
    return __submenuArrowSelectedColor;
}

+ (void)setSubmenuArrowSelectedColor:(NSColor *)color
{
    [color retain];
    [__submenuArrowSelectedColor release];
    __submenuArrowSelectedColor = color;
}


+ (NSDictionary *)menuItemTitleAttributes
{
    if(!__menuItemTitleAttributes){
        __menuItemTitleAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSColor textColor], NSForegroundColorAttributeName,
                                 [NSFont controlContentFontOfSize:12.0], NSFontAttributeName,
                                 nil];        
    }
    
    
    return __menuItemTitleAttributes;
}

+ (void)setMenuItemTitleAttributes:(NSDictionary *)dict
{
    NSDictionary *newAttributes = [dict copy];
    [__menuItemTitleAttributes release];
    __menuItemTitleAttributes = newAttributes;
}

+ (NSDictionary *)selectedMenuItemTitleAttributes
{
    if(!__selectedMenuItemTitleAttributes){
        __selectedMenuItemTitleAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSColor selectedMenuItemTextColor], NSForegroundColorAttributeName,
                              [NSFont controlContentFontOfSize:12.0], NSFontAttributeName,
                              nil];
        
    }
    
    return __selectedMenuItemTitleAttributes;
}

+ (void)setSelectedMenuItemTitleAttributes:(NSDictionary *)dict
{
    NSDictionary *newAttributes = [dict copy];
    [__selectedMenuItemTitleAttributes release];
    __selectedMenuItemTitleAttributes = newAttributes;
}


+ (BOOL)fillCentralMenuItem
{
    return __fillCentralMenuItem;
}

+ (void)setFillCentralMenuItem:(BOOL)flag
{
    __fillCentralMenuItem = flag;
}

+ (BOOL)openSubmenusOnMouseOver
{
    return __openSubmenusOnMouseOver;
}

+ (void)setOpenSubmenusOnMouseOver:(BOOL)flag
{
    __openSubmenusOnMouseOver = flag;
}

+ (NSTimeInterval)mouseOverMenuOpeningInterval
{
    return __mouseOverMenuOpeningInterval;
}

+ (void)setMouseOverMenuOpeningInterval:(NSTimeInterval)interval
{
    __mouseOverMenuOpeningInterval = interval;
}

+ (CGFloat)centralButtonRadius
{
    return __centralButtonRadius;
}

+ (void)setCentralButtonRadius:(CGFloat)r
{
    __centralButtonRadius = MIN(r, __menuRadius-10.);
}

+ (CGFloat)menuRadius
{
    return __menuRadius;
}

+ (void)setMenuRadius:(CGFloat)r
{
    __menuRadius = MAX(r, __centralButtonRadius+10.);
}
@end
