//
//  ERRadialMenuView.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ERRadialMenuItem.h"
#import <ERAppKit/ERGlobals.h>

#import "ERTimer.h"

#define OUTER_RADIUS 100.
#define INNER_RADIUS 30.

@class ERRadialMenuItem;

@interface ERRadialMenuView : NSView
{
    @protected
    NSMenu *_menu;
    NSArray *_radialMenuItems;
    
    @private
    ERMenuStyle _style;
    ERRadialMenuItem *_selectedItem;
    
    ERRadialMenuView *_supermenu;
    ERRadialMenuView *_submenu;
    
    ERTimer *_hitboxTimer;
}
@property (readonly,copy) NSArray *radialMenuItems;
@property (readonly) ERRadialMenuItem *selectedItem;
@property (readonly) NSMenu *menu;

- (id)initWithMenu:(NSMenu *)menu;
- (id)initWithMenu:(NSMenu *)menu style:(ERMenuStyle)style;
- (id)initWithCenteredMenu:(NSMenu *)menu;
- (id)initWithMenu:(NSMenu *)menu emptyAngle:(CGFloat)emptyAngle;


- (NSInteger)numberOfItems;

- (void)sendBack:(id)sender;
- (void)sendFront:(id)sender;
- (void)cascadingSendBack:(id)sender;
- (void)cascadingSendFront:(id)sender;
- (void)cascadingSendToLevel:(CGFloat)alpha;

- (void)windowResign;

- (void)selectItemUnderPoint:(NSPoint)location;
@end
