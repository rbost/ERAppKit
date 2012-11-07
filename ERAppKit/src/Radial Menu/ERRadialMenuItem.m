//
//  ERRadialMenuItem.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERRadialMenuItem.h"

#import <ERAppKit/ERMenu.h>
#import <ERAppKit/ERGeometry.h>

BOOL _ERPointInAngle(NSPoint p, CGFloat a1, CGFloat b1, CGFloat c1, CGFloat a2, CGFloat b2, CGFloat c2)
{
    return (a1*p.x + b1*p.y +c1 >= 0) && (a2*p.x + b2*p.y +c2 <= 0);
}

NSRect ERFitRectInAngle(NSRect startingRect, NSPoint centerPoint, CGFloat anglePos, CGFloat angleWidth)
{
    NSRect rect = startingRect;
    
    CGFloat theta1, theta2;
    theta1 = anglePos-angleWidth/2.; theta1 *= (M_PI/180.); // get angles in radians
    theta2 = anglePos+angleWidth/2.; theta2 *= (M_PI/180.);
    
    CGFloat a1,b1,c1; // the coefficients of the first line
    a1 = - sin(theta1); b1 = cos(theta1); c1 = -a1*centerPoint.x -b1*centerPoint.y;
    
    CGFloat a2,b2,c2; // the coefficients of the second line
    a2 = - sin(theta2); b2 = cos(theta2); c2 = -a2*centerPoint.x -b2*centerPoint.y;
    
    
    // the points inside the angle are over the first line and under the second line, use _ERPointInAngle to decide this
    
    NSPoint unitVector = NSMakePoint(cos((M_PI/180.)*anglePos), sin((M_PI/180.)*anglePos));
    NSPoint ul, ll, ur, lr; // respectively corners of the rectangle (upper-left, lower-left, ...)
    
    ul = NSMakePoint(NSMinX(rect), NSMaxY(rect));
    ll = NSMakePoint(NSMinX(rect), NSMinY(rect));
    ur = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
    lr = NSMakePoint(NSMaxX(rect), NSMinY(rect));
    
    while (!_ERPointInAngle(ul, a1, b1, c1, a2, b2, c2) || !_ERPointInAngle(ll, a1, b1, c1, a2, b2, c2) ||
           !_ERPointInAngle(ur, a1, b1, c1, a2, b2, c2) || !_ERPointInAngle(lr, a1, b1, c1, a2, b2, c2)) {
        ul.x += unitVector.x; ul.y += unitVector.y;
        ll.x += unitVector.x; ll.y += unitVector.y;
        ur.x += unitVector.x; ur.y += unitVector.y;
        lr.x += unitVector.x; lr.y += unitVector.y;
        
        rect.origin.x += unitVector.x;
        rect.origin.y += unitVector.y;
    }
    
    return rect;
}

NSPoint ERDrawingPointForAttributedStringInAngle(NSAttributedString *aStr, NSPoint centerPoint, CGFloat anglePos, CGFloat angleWidth, CGFloat minRadius)
{
    NSRect stringRect = NSZeroRect;
    stringRect.size = [aStr size];
    
    NSPoint firstCenter = NSMakePoint(minRadius*cos((M_PI/180.)*anglePos), minRadius*sin((M_PI/180.)*anglePos));
    stringRect = ERSetCenterPointOfRect(stringRect,firstCenter);
    
    stringRect = ERFitRectInAngle(stringRect, centerPoint, anglePos, angleWidth);
    
    return stringRect.origin;
}

@implementation ERRadialMenuItem

- (id)initWithMenuItem:(NSMenuItem *)item hitBox:(NSBezierPath *)bp isCentral:(BOOL)flag angle:(CGFloat)position inRadialMenuView:(ERRadialMenuView *)v
{
    self = [self init];
    
    [self setMenuItem:item];
    [self setHitBox:bp];
    _isCentral = flag;
    
    _angle = position;
    _menuView = v;

    if([item title])
        _attributedTitle = [[NSAttributedString alloc] initWithString:[item title] attributes:[ERMenu menuItemTitleAttributes]];
    
    return self;
}


-  (void)dealloc
{
    [_attributedTitle release];
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

    [attributedTitle drawAtPoint:[self titleDrawingPoint]];
    [attributedTitle release];
    
    if([[self menuItem] hasSubmenu]){
        CGFloat angularWidth = 2*M_PI/[_menuView numberOfItems];
        CGFloat radianFactor = M_PI/180.;
        NSBezierPath *arrow = [NSBezierPath bezierPath];
        CGFloat r1 = [[self menuView] radius] - ER_SUBMENU_INNER_OFFSET;
        CGFloat r2 = [[self menuView] radius] - ER_SUBMENU_OUTTER_OFFSET;
        
        [arrow moveToPoint:NSMakePoint(r1*cos(radianFactor*_angle - 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth), r1*sin(radianFactor*_angle - 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth))];
        [arrow lineToPoint:NSMakePoint(r2*cos(radianFactor*_angle), r2*sin(radianFactor*_angle))];
        [arrow lineToPoint:NSMakePoint(r1*cos(radianFactor*_angle + 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth), r1*sin(radianFactor*_angle + 0.5*ER_SUBMENU_ARROW_FRACTION*angularWidth))];
        
        [[NSColor colorWithCalibratedWhite:0.3 alpha:1.] set];
        [arrow setLineWidth:2.5];
        [arrow setLineCapStyle:NSRoundLineCapStyle];
        [arrow stroke];

    }
    
//    NSRect titleBox;
//    titleBox.origin = [self titleDrawingPoint];
//    titleBox.size = [_attributedTitle size];
//    [NSBezierPath strokeRect:titleBox];
    
    
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
        CGFloat r1 = [[self menuView] radius] - ER_SUBMENU_INNER_OFFSET;
        CGFloat r2 = [[self menuView] radius] - ER_SUBMENU_OUTTER_OFFSET;
        
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
@synthesize attributedTitle = _attributedTitle, titleDrawingPoint;

- (BOOL)hitTest:(NSPoint)p
{
    return [_hitBox containsPoint:p];
}
@end
