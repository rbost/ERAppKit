//
//  ERRadialMenuItem.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERRadialMenuItem.h"

NSGradient *__selectedItemGradient = nil;

@implementation ERRadialMenuItem

+ (NSDictionary *)menuTitleAttributes
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSColor textColor], NSForegroundColorAttributeName,
                          [NSFont controlContentFontOfSize:11.0], NSFontAttributeName,
                          nil];
    
    
    
    return dict;
}

+ (NSDictionary *)selectedMenuTitleAttributes
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSColor selectedMenuItemTextColor], NSForegroundColorAttributeName,
                          [NSFont controlContentFontOfSize:11.0], NSFontAttributeName,
                          nil];
    
    
    
    return dict;
}

+ (NSGradient *)selectedItemGradient
{
    if(!__selectedItemGradient){
        __selectedItemGradient = [[NSGradient alloc] initWithStartingColor:
                                  [NSColor colorWithCalibratedRed:.396 green:.541 blue:.941 alpha:1.]
                                                               endingColor:
                                  [NSColor colorWithCalibratedRed:.157 green:.384 blue:.929 alpha:1.]];
    }
    
    return __selectedItemGradient;
}

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
    
    if([self menuItem]){
        [[NSColor controlBackgroundColor] set];
        [_hitBox fill];

        [[NSColor colorWithCalibratedRed:0.898 green:0.898 blue:0.898 alpha:1] set];
        [_hitBox stroke];
        
        NSAttributedString *attributedTitle = nil;
        if([[self menuItem] attributedTitle]){
            attributedTitle = [[[self menuItem] attributedTitle] copy];
        }else if([[self menuItem] title]){
            attributedTitle = [[NSAttributedString alloc] initWithString:[[self menuItem] title] attributes:[[self class] menuTitleAttributes]];
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
        
    }
    
    [NSGraphicsContext restoreGraphicsState];

}

- (void)drawItemSelected
{
    [NSGraphicsContext saveGraphicsState];
    
    [[self hitBox] addClip]; // draw the gradient only in the item
    
    [[[self class] selectedItemGradient] drawFromCenter:NSZeroPoint radius:0 toCenter:NSZeroPoint radius:200 options:0];

    [[NSColor colorWithCalibratedRed:0.898 green:0.898 blue:0.898 alpha:1] set];
    [_hitBox stroke];
    
    NSAttributedString *attributedTitle = nil;
    if([[self menuItem] attributedTitle]){
        attributedTitle = [[[self menuItem] attributedTitle] copy];
    }else if([[self menuItem] title]){
        attributedTitle = [[NSAttributedString alloc] initWithString:[[self menuItem] title] attributes:[[self class] selectedMenuTitleAttributes]];
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
