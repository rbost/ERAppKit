//
//  ERRadialMenuView.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERRadialMenuView.h"

#import "ERRadialMenuWindow.h"
#import <ERAppKit/ERMenu.h>

#define ERMENU_MOUSEOVER_INTERVAL [ERMenu mouseOverMenuOpeningInterval]

@interface ERRadialMenuView ()
@property (readwrite,copy) NSArray *radialMenuItems; // we want the menu items to be assigned once, at the intialization
@property (assign) ERRadialMenuItem *selectedItem;
@property (assign) ERRadialMenuView *supermenu;
@property (retain) ERRadialMenuView *submenu;

- (void)_submenuResign;
- (void)_closeCascadingMenus;

- (void)_timerCallBack;

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
    return [self initWithMenu:menu style:ERDefaultMenuStyle];
}

- (id)initWithMenu:(NSMenu *)menu style:(ERMenuStyle)style
{
    _style = style;
    switch (style) {
        case ERCenteredMenuStyle:
            return [self initWithCenteredMenu:menu];
            break;
            
        case ERUpperMenuStyle:
            return [self initWithMenu:menu emptyAngle:180.];
            break;

        case EREmptyQuarterMenuStyle:
            return [self initWithMenu:menu emptyAngle:90.];
            break;

        default:
            return [self initWithCenteredMenu:menu];
            break;
    }
}

- (id)initWithCenteredMenu:(NSMenu *)menu
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
    
    
    _hitboxTimer = [[ERTimer alloc] initWithTimeInterval:ERMENU_MOUSEOVER_INTERVAL target:self selector:@selector(_timerCallBack) argument:nil];
    return self;
}

- (id)initWithMenu:(NSMenu *)menu emptyAngle:(CGFloat)emptyAngle;
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
        
        CGFloat itemAngle = (360.-emptyAngle)/[menuItems count];
        CGFloat currentAngle = 270.-emptyAngle/2.; // = -90 + 360 + empty/2
        CGFloat radianFactor = M_PI/180.;
        
        for (NSMenuItem *item in menuItems) {
            NSBezierPath *bp = [[NSBezierPath alloc] init];
            [bp appendBezierPathWithArcWithCenter:NSZeroPoint radius:INNER_RADIUS startAngle:(currentAngle) endAngle:(currentAngle-itemAngle) clockwise:YES];
            [bp appendBezierPathWithArcWithCenter:NSZeroPoint radius:OUTER_RADIUS startAngle:(currentAngle-itemAngle) endAngle:(currentAngle) clockwise:NO];
            [bp closePath];
            
            ERRadialMenuItem *rItem = [[ERRadialMenuItem alloc] initWithMenuItem:item hitBox:bp isCentral:NO angle:currentAngle-itemAngle/2. inRadialMenuView:self];
            
            CGFloat r = (INNER_RADIUS+OUTER_RADIUS)*.5;
            
            [rItem setCenterPoint:NSMakePoint(r*cos(radianFactor*(currentAngle-itemAngle/2)), r*sin(radianFactor*(currentAngle-itemAngle/2)))];
            [radialItems addObject:rItem];
            
            [rItem release];
            [bp release];
            
            currentAngle -= itemAngle; // turn clockwise
        }
        
        [self setRadialMenuItems:radialItems];
        [radialItems release];
        
    }
    
    
    [self setBoundsOrigin:NSMakePoint(-OUTER_RADIUS, -OUTER_RADIUS)];
    
    _hitboxTimer = [[ERTimer alloc] initWithTimeInterval:ERMENU_MOUSEOVER_INTERVAL target:self selector:@selector(_timerCallBack) argument:nil];

    return self;
}

- (void)dealloc
{
    [self setRadialMenuItems:nil];
    [self setSubmenu:nil];
    
    [_menu release];
    [_hitboxTimer stop];
    [_hitboxTimer release];
    
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

@synthesize radialMenuItems = _radialMenuItems, menu = _menu;
@synthesize submenu = _submenu, supermenu = _supermenu;
@dynamic selectedItem;

- (ERMenuStyle)style
{
    return _style;
}
- (ERRadialMenuItem *)selectedItem
{
    return _selectedItem;
}

- (void)setSelectedItem:(ERRadialMenuItem *)selectedItem
{
    _selectedItem = selectedItem;
    
    if ([ERMenu openSubmenusOnMouseOver]) {
        [_hitboxTimer reset];
    }
}

- (void)selectItemUnderPoint:(NSPoint)location
{
    if([self selectedItem] && [[self selectedItem] hitTest:location]){
        return; // do nothing, we are good
    }else{
        ERRadialMenuItem *selection = nil;
        for (ERRadialMenuItem *menuItem in [self radialMenuItems]) {
            if ([menuItem hitTest:location]) {
                selection = menuItem;
                [self setSelectedItem:menuItem];
                break;
            }
        }
        [self setSelectedItem:selection];

        [self setNeedsDisplay:YES];
        
        if(![self selectedItem]){
            [[self supermenu] resetItemSelection];
        }
    }
}

- (void)resetItemSelection
{
    NSPoint location = [[self window] mouseLocationOutsideOfEventStream];
    location = [self convertPoint:location fromView:nil];
    
    [self selectItemUnderPoint:location];
}

- (void)_timerCallBack
{
    if([self submenu]){
        return;
    }
    if(![self selectedItem] && [self supermenu]){
        // mouse outside the menu, let's close it
        [[self supermenu] closeSubmenu:self];
    }else if([[[self selectedItem] menuItem] hasSubmenu]){
        // open the submenu
        NSPoint location = [[self window] mouseLocationOutsideOfEventStream];
        location = [self convertPoint:location fromView:nil];
        ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:[[[self selectedItem] menuItem] submenu] atLocation:location inView:self menuStyle:[self style]];
        
        [(ERRadialMenuView *)[menuWindow contentView] setSupermenu:self];
        [self setSubmenu:[menuWindow contentView]];
        
        [menuWindow makeKeyAndOrderFront:self];
        [menuWindow fadeIn:self];
        [menuWindow setReleasedWhenClosed:YES];
        [self cascadingSendBack:self];
        
        _selectedItem = nil;
        [self setNeedsDisplay:YES];

    }
}

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
        [self selectItemUnderPoint:location];
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    [self selectItemUnderPoint:location];
}

- (void)mouseUp:(NSEvent *)theEvent
{
//    NSLog(@"mouse up");
    // get the selected menu item
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [self selectItemUnderPoint:location];
     
    [self setNeedsDisplay:YES];
    
    if (![self selectedItem]) {
        return;
    }
    // trigger action depending on the selected item

    if ([[self selectedItem] isCentral]) {
        if ([self supermenu]) {
            [[self supermenu] closeSubmenu:self];

        }else{ // we are the main menu
            [[self window] close];
        }
    }else{
        NSMenuItem *item = [[self selectedItem] menuItem];
        
        if ([item hasSubmenu]) {
            // open a new menu for the submenu
            ERRadialMenuWindow *menuWindow = [[ERRadialMenuWindow alloc] initWithMenu:[item submenu] atLocation:location inView:self menuStyle:[self style]];
            
            [(ERRadialMenuView *)[menuWindow contentView] setSupermenu:self];
            [self setSubmenu:[menuWindow contentView]];
            
            [menuWindow makeKeyAndOrderFront:self];
            [menuWindow fadeIn:self];
            [menuWindow setReleasedWhenClosed:YES];
            [self cascadingSendBack:self];
            
            [self setSelectedItem:nil];
            [self setNeedsDisplay:YES];

            
        }else{
            [NSApp sendAction:[item action] to:[item target] from:item];
            [[self supermenu] _closeCascadingMenus];
            [[self window] close];
            
        }
    }


}

- (void)windowResign
{
//   NSLog(@"window resigns");
    if ([self submenu]) {
        // we have a submenu
    }else{
        // we are the top menu

        // tell the supermenu we are resigning
        ERRadialMenuView *superMenu = [self supermenu];
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
        [[self submenu] setSupermenu:nil];
        [self setSubmenu:nil];
        [[self window] makeKeyWindow];
//        [self cascadingSendFront:self];
        [self cascadingSendToLevel:1.0];

    }else{
        // mouse outside -> close
        [[self supermenu] _submenuResign];
        [[self window] close];
    }
    
}

- (void)closeSubmenu:(id)sender
{
//    NSLog(@"close submenu");
    ERRadialMenuView *sub = [self submenu];
    [[self submenu] setSupermenu:nil];
    [self setSubmenu:nil];
    [[sub window] close];
    [[self window] makeKeyWindow];
    [self cascadingSendFront:self];
    [self resetItemSelection];
}

- (void)_closeCascadingMenus
{
    [[self submenu] setSupermenu:nil];
    [self setSubmenu:nil];
    [[self supermenu] _closeCascadingMenus];
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

    [[self supermenu] cascadingSendBack:sender];
}

- (void)sendFront:(id)sender
{
    if([[self window] respondsToSelector:@selector(fadeFront:)])
        [(ERRadialMenuWindow *)[self window] fadeFront:sender];
}

- (void)cascadingSendFront:(id)sender
{
    [self sendFront:sender];
    
    [[self supermenu] cascadingSendFront:sender];
}

- (void)cascadingSendToLevel:(CGFloat)alpha
{
    if([[self window] respondsToSelector:@selector(fadeToAlpha:)])
        [(ERRadialMenuWindow *)[self window] fadeToAlpha:alpha];
    
    [[self supermenu] cascadingSendToLevel:alpha/2.];

}

@end
