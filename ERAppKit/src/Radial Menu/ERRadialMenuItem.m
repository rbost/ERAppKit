//
//  ERRadialMenuItem.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERRadialMenuItem.h"

#import <ERAppKit/ERMenu.h>

@implementation ERRadialMenuItem

- (id)initWithMenuItem:(NSMenuItem *)item hitBox:(NSBezierPath *)bp isCentral:(BOOL)flag angle:(CGFloat)position inRadialMenuView:(ERRadialMenuView *)v
{
    self = [self init];
    
    [self setMenuItem:item];
    [self setHitBox:bp];
    _isCentral = flag;
    
    _angle = position;
    _menuView = v;

    return self;
}


-  (void)dealloc
{
    [self setMenuItem:nil];
    [self setHitBox:nil];
    
    [super dealloc];
}

- (void)drawItem
{
    [NSGraphicsContext saveGraphicsState];
    
    if([ERMenu fillCentralMenuItem] || ![self isCentral]){
        
        if ([ERMenu itemColor]) {
            [[ERMenu itemColor] set];
            [_hitBox fill];
        }else{
            [[ERMenu itemGradient] drawFromCenter:NSZeroPoint radius:0 toCenter:NSZeroPoint radius:200 options:0];
        }
    }

    [[ERMenu itemStrokeColor] set];
    [_hitBox stroke];
    
    NSAttributedString *attributedTitle = nil;
    if([[self menuItem] attributedTitle]){
        attributedTitle = [[[self menuItem] attributedTitle] copy];
    }else if([[self menuItem] title]){
        attributedTitle = [[NSAttributedString alloc] initWithString:[[self menuItem] title] attributes:[ERMenu menuItemTitleAttributes]];
    }

    NSSize titleSize = [attributedTitle size];
    NSPoint drawLocation = [self centerPoint];
    
    drawLocation.x -= titleSize.width/2.;
    drawLocation.y -= titleSize.height/2.;

    [attributedTitle drawAtPoint:drawLocation];
    [attributedTitle release];
    
    if([[self menuItem] hasSubmenu]){
        CGFloat angularWidth = 2*M_PI/[_menuView numberOfItems];
        CGFloat radianFactor = M_PI/180.;
        NSBezierPath *arrow = [NSBezierPath bezierPath];
        CGFloat r1 = OUTER_RADIUS - ER_SUBMENU_INNER_OFFSET;
        CGFloat r2 = OUTER_RADIUS - ER_SUBMENU_OUTTER_OFFSET;
        
        [arrow moveToPoint:NSMakePoint(r1*cos(radianFactor*_angle - 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth), r1*sin(radianFactor*_angle - 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth))];
        [arrow lineToPoint:NSMakePoint(r2*cos(radianFactor*_angle), r2*sin(radianFactor*_angle))];
        [arrow lineToPoint:NSMakePoint(r1*cos(radianFactor*_angle + 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth), r1*sin(radianFactor*_angle + 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth))];
        
        [[NSColor colorWithCalibratedWhite:0.3 alpha:1.] set];
        [arrow setLineWidth:2.5];
        [arrow setLineCapStyle:NSRoundLineCapStyle];
        [arrow stroke];

    }
    
    [NSGraphicsContext restoreGraphicsState];

}

- (void)drawItemSelected
{
    [NSGraphicsContext saveGraphicsState];
    
    [[self hitBox] addClip]; // draw the gradient only in the item
    
    if ([ERMenu selectedItemColor]) {
        [[ERMenu selectedItemColor] set];
        [_hitBox fill];
    }else{
        [[ERMenu selectedItemGradient] drawFromCenter:NSZeroPoint radius:0 toCenter:NSZeroPoint radius:200 options:0]; 
    }

    [[ERMenu selectedItemStrokeColor] set];
    [_hitBox stroke];
    
    NSAttributedString *attributedTitle = nil;
    if([[self menuItem] attributedTitle]){
        attributedTitle = [[[self menuItem] attributedTitle] copy];
    }else if([[self menuItem] title]){
        attributedTitle = [[NSAttributedString alloc] initWithString:[[self menuItem] title] attributes:[ERMenu selectedMenuItemTitleAttributes]];
    }
    
    NSSize titleSize = [attributedTitle size];
    NSPoint drawLocation = [self centerPoint];
    
    
    drawLocation.x -= titleSize.width/2.;
    drawLocation.y -= titleSize.height/2.;
    
    [attributedTitle drawAtPoint:drawLocation];
    [attributedTitle release];

    if([[self menuItem] hasSubmenu]){
        CGFloat angularWidth = 2*M_PI/[_menuView numberOfItems];
        CGFloat radianFactor = M_PI/180.;
        NSBezierPath *arrow = [NSBezierPath bezierPath];
        CGFloat r1 = OUTER_RADIUS - ER_SUBMENU_INNER_OFFSET;
        CGFloat r2 = OUTER_RADIUS - ER_SUBMENU_OUTTER_OFFSET;
        
        [arrow moveToPoint:NSMakePoint(r1*cos(radianFactor*_angle - 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth), r1*sin(radianFactor*_angle - 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth))];
        [arrow lineToPoint:NSMakePoint(r2*cos(radianFactor*_angle), r2*sin(radianFactor*_angle))];
        [arrow lineToPoint:NSMakePoint(r1*cos(radianFactor*_angle + 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth), r1*sin(radianFactor*_angle + 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth))];
        
        [[NSColor selectedMenuItemTextColor] set];
        [arrow setLineWidth:2.5];
        [arrow setLineCapStyle:NSRoundLineCapStyle];
        [arrow stroke];
        
    }

    [NSGraphicsContext restoreGraphicsState];
    
}

@synthesize hitBox = _hitBox, menuItem = _menuItem, centerPoint;
@synthesize isCentral = _isCentral, angle = _angle, menuView = _menuView;

- (BOOL)hitTest:(NSPoint)p
{
    return [_hitBox containsPoint:p];
}
@end
