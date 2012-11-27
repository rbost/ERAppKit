//
//  ERRadialMenuItem.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ERRadialMenuView.h"
@class ERRadialMenuView;


#define ER_SUBMENU_OUTTER_OFFSET 05
#define ER_SUBMENU_INNER_OFFSET 10
#define ER_SUBMENU_ARROW_FRACTION 0.5

NSRect ERFitRectInAngle(NSRect startingRect, NSPoint centerPoint, CGFloat anglePos, CGFloat angleWidth);
NSPoint ERDrawingPointForAttributedStringInAngle(NSAttributedString *aStr, NSPoint centerPoint, CGFloat anglePos, CGFloat angleWidth, CGFloat minRadius);


@interface ERRadialMenuItem : NSObject
{
    NSMenuItem *_menuItem;
    NSBezierPath *_hitBox;
 
    @private
    BOOL _isCentral;
    CGFloat _angle;
    ERRadialMenuView *_menuView;
    
    NSAttributedString *_attributedTitle;
}

@property (retain)      NSMenuItem *menuItem;
@property (retain)      NSBezierPath *hitBox;
@property (assign)      NSPoint centerPoint;
@property (readonly)    BOOL isCentral;
@property (readonly)    CGFloat angle;
@property (readonly)    ERRadialMenuView *menuView;
@property (readonly)    NSAttributedString *attributedTitle;

@property (assign) NSPoint titleDrawingPoint;

- (id)initWithMenuItem:(NSMenuItem *)item hitBox:(NSBezierPath *)bp isCentral:(BOOL)flag angle:(CGFloat)position inRadialMenuView:(ERRadialMenuView *)v;
- (void)drawItem;
- (void)drawItemSelected;
- (BOOL)hitTest:(NSPoint)p;

@end
