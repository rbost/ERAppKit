//
//  ERRadialMenuView.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERRadialMenuView.h"

#import "ERRadialMenuWindow.h"

@interface ERRadialMenuView ()
@property (readwrite,copy) NSArray *radialMenuItems; // we want the menu items to be assigned once, at the intialization
@property (assign) ERRadialMenuItem *selectedItem;
@property (assign) ERRadialMenuView *superMenu;
@property (retain) ERRadialMenuView *subMenu;

- (void)_submenuResign;
- (void)_closeCascadingMenus;

@end


@implementation ERRadialMenuView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithMenu:(NSMenu *)menu
{
    self = [self initWithFrame:NSMakeRect(0, 0, 2*OUTER_RADIUS, 2*OUTER_RADIUS)];
    
    if(self){
        _menu = [menu retain];
        NSArray *menuItems = [menu itemArray];
        NSMutableArray *radialItems = [[NSMutableArray alloc] initWithCapacity:([menuItems count]+1)];
        
        ERRadialMenuItem *centerItem = [[ERRadialMenuItem alloc] initWithMenuItem:nil hitBox:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-INNER_RADIUS, -INNER_RADIUS, 2*INNER_RADIUS, 2*INNER_RADIUS)] isCentral:YES angle:0. inRadialMenuView:self];
        
        
        [radialItems addObject:centerItem];
        [self setSelectedItem:centerItem];
        [centerItem release];
        
        CGFloat itemAngle = 360./[menuItems count];
        CGFloat currentAngle = 90.;
        CGFloat radianFactor = M_PI/180.;
        
        for (NSMenuItem *item in menuItems) {
            NSBezierPath *bp = [[NSBezierPath alloc] init];
            [bp appendBezierPathWithArcWithCenter:NSZeroPoint radius:INNER_RADIUS startAngle:(currentAngle+itemAngle/2) endAngle:(currentAngle-itemAngle/2) clockwise:YES];
            [bp appendBezierPathWithArcWithCenter:NSZeroPoint radius:OUTER_RADIUS startAngle:(currentAngle-itemAngle/2) endAngle:(currentAngle+itemAngle/2) clockwise:NO];
            [bp closePath];
        
            ERRadialMenuItem *rItem = [[ERRadialMenuItem alloc] initWithMenuItem:item hitBox:bp isCentral:NO angle:currentAngle inRadialMenuView:self];
            
            CGFloat r = (INNER_RADIUS+OUTER_RADIUS)*.5;
            
            [rItem setCenterPoint:NSMakePoint(r*cos(radianFactor*currentAngle), r*sin(radianFactor*currentAngle))];
            [radialItems addObject:rItem];
            
            [rItem release];
            [bp release];
            
            currentAngle -= itemAngle; // turn clockwise
        }
        
        [self setRadialMenuItems:radialItems];
        [radialItems release];
    
    }
    

    [self setBoundsOrigin:NSMakePoint(-OUTER_RADIUS, -OUTER_RADIUS)];
    return self;
}

- (void)dealloc
{
    [self setRadialMenuItems:nil];
    [self setSubMenu:nil];
    
    [_menu release];
    
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
   
    [NSGraphicsContext saveGraphicsState];
    
    for (ERRadialMenuItem *menuItem in [self radialMenuItems]) {
        if(menuItem == [self selectedItem])
            [menuItem drawItemSelected];
        else
            [menuItem drawItem];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@synthesize radialMenuItems = _radialMenuItems, selectedItem = _selectedItem, menu = _menu;

- (NSInteger)numberOfItems
{
    return [_menu numberOfItems];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if([self selectedItem] && [[self selectedItem] hitTest:location]){
        return; // do nothing, we are good
    }else{
        [self setSelectedItem:nil];
        for (ERRadialMenuItem *menuItem in [self radialMenuItems]) {
            if ([menuItem hitTest:location]) {
                [self setSelectedItem:menuItem];
            }
        }
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if([self selectedItem] && [[self selectedItem] hitTest:location]){
        return; // do nothing, we are good
    }else{
        [self setSelectedItem:nil];
        for (ERRadialMenuItem *menuItem in [self radialMenuItems]) {
            if ([menuItem hitTest:location]) {
                [self setSelectedItem:menuItem];
            }
        }
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
//    NSLog(@"mouse up");
    // get the selected menu item
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if([self selectedItem] && [[self selectedItem] hitTest:location]){
        // do nothing, we are good
    }else{
        [self setSelectedItem:nil];
        for (ERRadialMenuItem *menuItem in [self radialMenuItems]) {
            if ([menuItem hitTest:location]) {
                [self setSelectedItem:menuItem];
            }
        }
        [self setNeedsDisplay:YES];
    }
    
    if (![self selectedItem]) {
        return;
    }
    // trigger action depending on the selected item

    if ([[self selectedItem] isCentral]) {
        if ([self superMenu]) {
            [[self superMenu] closeSubmenu:self];

        }else{ // we are the main menu
            [[self window] close];
        }
    }else{
        NSMenuItem *item = [[self selectedItem] menuItem];
        
        if ([item hasSubmenu]) {
            // open a new menu for the submenu
            ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:[item submenu] atLocation:[[self selectedItem] centerPoint] inView:self];
            
            [(ERRadialMenuView *)[menuWindow contentView] setSuperMenu:self];
            [self setSubMenu:[menuWindow contentView]];
            
            [menuWindow makeKeyAndOrderFront:self];
            [menuWindow fadeIn:self];
            [menuWindow setReleasedWhenClosed:YES];
            [self cascadingSendBack:self];
            
            [self setSelectedItem:nil];
            [self setNeedsDisplay:YES];

            
        }else{
            [NSApp sendAction:[item action] to:[item target] from:item];
            [[self superMenu] _closeCascadingMenus];
            [[self window] close];
            
        }
    }


}

- (void)windowResign
{
//   NSLog(@"window resigns");
    if ([self subMenu]) {
        // we have a submenu
    }else{
        // we are the top menu

        // tell the supermenu we are resigning
        ERRadialMenuView *superMenu = [self superMenu];
        // close ourself
        [[self window] close];

        [superMenu _submenuResign];
        
    }
}

- (void)_submenuResign
{
    NSPoint location = [[self window] mouseLocationOutsideOfEventStream];
    location = [self convertPoint:location fromView:nil];
    
    // try to determine if the mouse is over the menu
    
    if([self selectedItem] && [[self selectedItem] hitTest:location]){
        // do nothing, we are good
    }else{
        [self setSelectedItem:nil];
        for (ERRadialMenuItem *menuItem in [self radialMenuItems]) {
            if ([menuItem hitTest:location]) {
                [self setSelectedItem:menuItem];
            }
        }
        [self setNeedsDisplay:YES];
    }
    
    if([self selectedItem]){
        // the click happened in our menu, great !
        [[self subMenu] setSuperMenu:nil];
        [self setSubMenu:nil];
        [[self window] makeKeyWindow];
//        [self cascadingSendFront:self];
        [self cascadingSendToLevel:1.0];

    }else{
        // mouse outside -> close
        [[self superMenu] _submenuResign];
        [[self window] close];
    }
    
}

- (void)closeSubmenu:(id)sender
{
//    NSLog(@"close submenu");
    ERRadialMenuView *sub = [self subMenu];
    [[self subMenu] setSuperMenu:nil];
    [self setSubMenu:nil];
    [[sub window] close];
    [[self window] makeKeyWindow];
    [self cascadingSendFront:self];
}

- (void)_closeCascadingMenus
{
    [[self subMenu] setSuperMenu:nil];
    [self setSubMenu:nil];
    [[self superMenu] _closeCascadingMenus];
    [[self window] close];
}
- (void)sendBack:(id)sender
{
    if([[self window] respondsToSelector:@selector(fadeBack:)])
        [(ERRadialMenuWindow *)[self window] fadeBack:sender];
}

- (void)cascadingSendBack:(id)sender
{
    [self sendBack:sender];

    [[self superMenu] cascadingSendBack:sender];
}

- (void)sendFront:(id)sender
{
    if([[self window] respondsToSelector:@selector(fadeFront:)])
        [(ERRadialMenuWindow *)[self window] fadeFront:sender];
}

- (void)cascadingSendFront:(id)sender
{
    [self sendFront:sender];
    
    [[self superMenu] cascadingSendFront:sender];
}

- (void)cascadingSendToLevel:(CGFloat)alpha
{
    if([[self window] respondsToSelector:@selector(fadeToAlpha:)])
        [(ERRadialMenuWindow *)[self window] fadeToAlpha:alpha];
    
    [[self superMenu] cascadingSendToLevel:alpha/2.];

}

@end
