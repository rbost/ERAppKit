//
//  ERPalettePanel.m
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPalettePanel.h"

#import <ERAppKit/ERPaletteContentView.h>
#import <ERAppKit/ERPaletteTabView.h>
#import <ERAppKit/ERPaletteHolderView.h>

#import "ERPaletteTitleView.h"
#import "ERPaletteTab.h"

NSString *ERPaletteDidCloseNotification = @"Palette did close";
NSString *ERPaletteDidOpenNotification = @"Palette did open";
NSString *ERPaletteNewFrameKey = @"New palette frame";
NSString *ERPalettePboardType = @"erappkit.palettePboardType";

static CGFloat __tabWidth = 40.;
static CGFloat __tabHeight = 30.;

@implementation ERPalettePanel

+(CGFloat)tabWidth
{
    return __tabWidth;
}

+(CGFloat)tabHeight
{
    return __tabHeight;
}

+ (NSSize)tabSizeForPanelPosition:(ERPalettePanelPosition)pos
{
    if (pos == ERPalettePanelPositionUp || pos == ERPalettePanelPositionDown) {
        return NSMakeSize([self tabWidth], [self tabHeight]);
    }else{
        return NSMakeSize([self tabHeight],[self tabWidth]);
    }
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    self = [super initWithContentRect:contentRect styleMask:(NSUtilityWindowMask) backing:bufferingType defer:deferCreation];

    ERPaletteContentView *contentView = [[ERPaletteContentView alloc] initWithFrame:NSMakeRect(0, 0, contentRect.size.width, contentRect.size.height)];
    [self setContentView:contentView];

    _state = ERPaletteClosed;
    _openingDirection = ERPaletteInsideOpeningDirection;
    _preferedOpeningDirection = ERPaletteInsideOpeningDirection;

    return self;
}

- (id)initWithContent:(NSView *)content position:(ERPalettePanelPosition)pos
{
    _palettePosition = pos;
    NSRect contentRect;
    contentRect.size = [content frame].size;
    contentRect.origin = NSMakePoint(400, 400);
    
    if ([self palettePosition] == ERPalettePanelPositionDown || [self palettePosition] == ERPalettePanelPositionUp) {
        contentRect.size.height += [ERPaletteContentView paletteTitleHeight];
    }else{
        contentRect.size.width += [ERPaletteContentView paletteTitleHeight];
    }

    self = [self initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];

    [self setContent:content];
    
    _titleView = [[ERPaletteTitleView alloc] initWithFrame:[[self contentView] headerRect]];
    [[self contentView] addSubview:_titleView];
    [_titleView release];
    
    _tabButton = [[ERPaletteTab alloc] initWithFrame:[self tabRect]];
    [[self contentView] addSubview:_tabButton];
    [_tabButton release];
    [_tabButton setPalette:self];

    [self updateFrameSize];
    [self updateContentPlacement];
    [self updateTitleViewPlacement:NO];
    [self updateAutoresizingMask];
    
    [self setFloatingPanel:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setOpaque:NO];
    [self setHasShadow:YES];
    
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)sendEvent:(NSEvent *)event
{
    // make ourself key so the header can be dragged immediately
    [self makeKeyWindow];

    [super sendEvent:event];
}
- (ERPalettePanelPosition)palettePosition
{
    return _palettePosition;
}

- (void)setPalettePosition:(ERPalettePanelPosition)palettePosition
{
    if (palettePosition == _palettePosition) {
        return;
    }
    
    _palettePosition = palettePosition;
    [_tabButton setFrameSize:[self tabSize]];
    [_tabButton setNeedsDisplay:YES];

    // update the content autosizing mask with respect to the new position of the palette
    [self updateFrameSize];
    [self updateContentPlacement];
    [self updateAutoresizingMask];
    [[self contentView] setNeedsDisplay:YES];
}

- (ERPalettePanelPosition)effectiveHeaderPosition
{
    ERPalettePanelPosition pos = [self palettePosition];
    if ([self openingDirection] == ERPaletteInsideOpeningDirection) {
        pos = (pos + 2)%4;
    }
    return pos;
}


//@synthesize openingDirection = _openingDirection;

- (ERPaletteOpeningDirection)openingDirection
{
    return _openingDirection;
}

- (void)setOpeningDirection:(ERPaletteOpeningDirection)openingDirection
{
    _openingDirection = openingDirection;
//    [self updateFrameSize];
    [self updateContentPlacement];
    [self updateAutoresizingMask];
}

- (NSRect)contentFrameForOpeningDirection:(ERPaletteOpeningDirection)dir
{
    ERPalettePanelPosition pos = [self palettePosition];
    if (dir == ERPaletteInsideOpeningDirection) {
        pos = (pos + 2)%4;
    }
    NSRect frame;
    
    frame.origin = [_tabButton frame].origin;
    frame.size = [self paletteContentSize];
    
    switch (pos) {
        case ERPalettePanelPositionUp:
            frame.origin.y += [ERPalettePanel tabHeight];
            break;
        case ERPalettePanelPositionDown:
            frame.origin.y -= frame.size.height;
            break;
        case ERPalettePanelPositionRight:
            frame.origin.x += [ERPalettePanel tabHeight];
            frame.origin.y -= [[self content] frame].size.height;
            break;
        case ERPalettePanelPositionLeft:
            frame.origin.x -= [[self content] frame].size.width;
            frame.origin.y -= [[self content] frame].size.height;
            break;
            
        default:
            break;
    }
    
    return [self convertRectToScreen:frame];
}

@synthesize preferedOpeningDirection = _preferedOpeningDirection;

- (ERPaletteOpeningDirection)bestOpeningDirection
{
    ERPaletteOpeningDirection dir = [self preferedOpeningDirection];
    if ([[self holder] isFrameEmptyFromPalettes:[self contentFrameForOpeningDirection:dir] except:self]) {
        return dir;
    }
    dir = (dir == ERPaletteInsideOpeningDirection)? ERPaletteOutsideOpeningDirection : ERPaletteInsideOpeningDirection;
    if ([[self holder] isFrameEmptyFromPalettes:[self contentFrameForOpeningDirection:dir] except:self]) {
        return dir;
    }
    
    return [self preferedOpeningDirection];
}

- (void)updateAutoresizingMask
{
    NSUInteger mask;
    
    switch ([self effectiveHeaderPosition]) {
        case ERPalettePanelPositionUp:
            mask = NSViewMaxYMargin;
            break;
            
        case ERPalettePanelPositionDown:
            mask = NSViewMinYMargin;
            break;
            
        case ERPalettePanelPositionLeft:
            mask = NSViewMinXMargin|NSViewMinYMargin;
            break;
            
        case ERPalettePanelPositionRight:
            mask = NSViewMaxXMargin|NSViewMinYMargin;
            break;
            
        default:
            break;
    }
    [[self content] setAutoresizingMask:mask];

    switch ([self effectiveHeaderPosition]) {
        case ERPalettePanelPositionUp:
            mask = NSViewMaxYMargin;
            break;
            
        case ERPalettePanelPositionDown:
            mask = NSViewMinYMargin;
            break;
            
        case ERPalettePanelPositionLeft:
            mask = NSViewMinXMargin|NSViewMinYMargin;
            break;
            
        case ERPalettePanelPositionRight:
            mask = NSViewMaxXMargin|NSViewMinYMargin;
            break;
            
        default:
            break;
    }
    
    [_titleView setAutoresizingMask:mask];
    [_tabButton setAutoresizingMask:mask];
}

- (void)updateFrameSize
{
    NSRect frame = [self frame];
    
    frame.size = [self paletteSize];
    [self setFrame:frame display:YES];
}

- (void)updateContentPlacement
{
    NSPoint frameOrigin = NSZeroPoint;
    ERPalettePanelPosition pos = [self effectiveHeaderPosition];
    NSRect tabRect = [self tabRect];

    if (pos == ERPalettePanelPositionUp) {
        frameOrigin.y = [ERPaletteContentView paletteTitleHeight]+[ERPalettePanel tabHeight];
    }else if(pos == ERPalettePanelPositionDown) {
        frameOrigin.y = NSMinY(tabRect) - [ERPaletteContentView paletteTitleHeight] - [[self content] frame].size.height;
    }else if (pos == ERPalettePanelPositionRight) {
        frameOrigin.x = [ERPalettePanel tabHeight];
        frameOrigin.y = NSMaxY(tabRect) - [ERPaletteContentView paletteTitleHeight] - [[self content] frame].size.height;
    }else if (pos == ERPalettePanelPositionLeft) {
        frameOrigin.x = NSMinX(tabRect) - [[self content] frame].size.width;
        frameOrigin.y = NSMaxY(tabRect) - [ERPaletteContentView paletteTitleHeight] - [[self content] frame].size.height;
    }
    
    [_content setFrameOrigin:frameOrigin];
    
//    [self updateTitleViewPlacement];
    
    [_tabButton setFrameOrigin:[self tabRect].origin];
}

- (void)updateTitleViewPlacement:(BOOL)animate
{
    NSPoint frameOrigin = NSZeroPoint;
    ERPalettePanelPosition pos = [self effectiveHeaderPosition];
    NSRect tabRect = [self tabRect];

    if ([self state] == ERPaletteTooltip) {
        NSRect tabButtonRect = [_tabButton convertRect:[_tabButton drawnButtonRect] toView:nil];
        
        
        if (pos == ERPalettePanelPositionUp) {
            frameOrigin = NSMakePoint(NSMinX(tabRect), NSMaxY(tabButtonRect));
        }else if(pos == ERPalettePanelPositionDown) {
            frameOrigin = NSMakePoint(NSMinX(tabRect), NSMinY(tabButtonRect)-[_titleView frame].size.height);
        }else if (pos == ERPalettePanelPositionRight) {
            frameOrigin = NSMakePoint(NSMaxX(tabButtonRect), NSMaxY(tabButtonRect)-[_titleView frame].size.height);
        }else if (pos == ERPalettePanelPositionLeft) {
            frameOrigin = NSMakePoint(NSMinX(tabButtonRect)-[_titleView frame].size.width, NSMaxY(tabButtonRect)-[_titleView frame].size.height);
        }
    }else{
        if (pos == ERPalettePanelPositionUp) {
            frameOrigin = NSMakePoint(NSMinX(tabRect), NSMaxY(tabRect));
        }else if(pos == ERPalettePanelPositionDown) {
            frameOrigin = NSMakePoint(NSMinX(tabRect), NSMinY(tabRect)-[_titleView frame].size.height);
        }else if (pos == ERPalettePanelPositionRight) {
            frameOrigin = NSMakePoint(NSMaxX(tabRect), NSMaxY(tabRect)-[_titleView frame].size.height);
        }else if (pos == ERPalettePanelPositionLeft) {
            frameOrigin = NSMakePoint(NSMinX(tabRect)-[_titleView frame].size.width, NSMaxY(tabRect)-[_titleView frame].size.height);
        }
    }
    if (animate) {
        [[_titleView animator] setFrameOrigin:frameOrigin];
    }else{
        [_titleView setFrameOrigin:frameOrigin];        
    }
}

- (ERPaletteState)state
{
    return _state;
}

- (void)setState:(ERPaletteState)state
{
    [self setState:state animate:NO];
}
- (void)setState:(ERPaletteState)state animate:(BOOL)animate
{
    if (state == _state) {
        return;
    }
    NSRect newFrame;
    
    if (state == ERPaletteClosed) {
        NSRect tabFrame = [self tabRect];
        tabFrame = [[self contentView] convertRect:tabFrame toView:nil];
        tabFrame = [self convertRectToScreen:tabFrame];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidCloseNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:tabFrame] forKey:ERPaletteNewFrameKey]];

        newFrame = tabFrame;
    }else if (state == ERPaletteOpened) {
        NSSize contentSize = [self paletteContentSize];
        NSRect tabFrame;
        newFrame.size = [self openedPaletteSize];
        
        tabFrame = [self tabRect];
        
        ERPalettePanelPosition pos = [self effectiveHeaderPosition];
        
        switch (pos) {
            case ERPalettePanelPositionLeft:
                newFrame.origin.x = NSMinX(tabFrame) - contentSize.width;
                newFrame.origin.y = NSMaxY(tabFrame) - contentSize.height;
                break;

            case ERPalettePanelPositionRight:
                newFrame.origin.x = NSMinX(tabFrame);
                newFrame.origin.y = NSMaxY(tabFrame) - contentSize.height;
                break;

            case ERPalettePanelPositionUp:
                newFrame.origin = tabFrame.origin;
                break;

            case ERPalettePanelPositionDown:
                newFrame.origin.x = NSMinX(tabFrame);
                newFrame.origin.y = NSMinY(tabFrame) - contentSize.height;
                break;

            default:
                break;
        }
        newFrame = [[self contentView] convertRect:newFrame toView:nil];
        newFrame = [self convertRectToScreen:newFrame];

        NSRect contentFrame = [self contentFrameForOpeningDirection:[self openingDirection]];
        [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidOpenNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:contentFrame] forKey:ERPaletteNewFrameKey]];
        
    }else if(state == ERPaletteTooltip) {
        NSRect headerRect, tabRect;
        headerRect = [self headerRect];
        tabRect = [self tabRect];
        
        newFrame = tabRect;
        
        
        ERPalettePanelPosition pos = [self effectiveHeaderPosition];
        
        switch (pos) {
            case ERPalettePanelPositionLeft:
                newFrame.size.width += [self paletteContentSize].width;
                newFrame.origin.x -= [self paletteContentSize].width;
                break;
                
            case ERPalettePanelPositionRight:
                newFrame.size.width += [self paletteContentSize].width;
                break;
                
            case ERPalettePanelPositionUp:
                newFrame.size.width = [self paletteContentSize].width;
                newFrame.size.height += [ERPaletteContentView paletteTitleHeight];
                break;
                
            case ERPalettePanelPositionDown:
                newFrame.size.width = [self paletteContentSize].width;
                newFrame.size.height += [ERPaletteContentView paletteTitleHeight];
                newFrame.origin.y -= [ERPaletteContentView paletteTitleHeight];
                break;
                
            default:
                break;
        }

        newFrame = [self convertRectToScreen:newFrame];
        
    }

    if (animate) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setCompletionHandler:^{[self updateTitleViewPlacement:YES];}];
//        [[NSAnimationContext currentContext] setDuration:2.];

        [[self animator] setFrame:newFrame display:YES];
        
        [NSAnimationContext endGrouping];
    }else{
        [self setFrame:newFrame display:YES];
    }
    

    [_titleView updateCloseButtonPosition];

    ERPaletteState oldState = _state;
    _state = state;

    if ([self state] == ERPaletteTooltip || (oldState == ERPaletteTooltip && [self state] == ERPaletteClosed)) {
        [_content setHidden:YES];
    }else{
        [_content setHidden:NO];
    }
    
    if(oldState == ERPaletteClosed)
        [self updateTitleViewPlacement:NO];
    
}

- (IBAction)collapse:(id)sender
{
    [self setState:ERPaletteClosed animate:YES];
}

- (IBAction)openInBestDirection:(id)sender
{
    [self setOpeningDirection:[self bestOpeningDirection]];
    [self setState:ERPaletteOpened animate:YES];
}

- (IBAction)toggleCollapse:(id)sender
{
    if (! [self isAttached]) { // if the palette is detached, do nothing
        return;
    }
    if (_state == ERPaletteOpened) {
        [self collapse:sender];
    }else{
        [self openInBestDirection:sender];
    }
}

- (IBAction)showTooltip:(id)sender
{
    if ([self state] != ERPaletteClosed) {
        return;
    }
    [self setOpeningDirection:[self bestOpeningDirection]];
    [self setState:ERPaletteTooltip animate:YES];
}

- (IBAction)openUp:(id)sender
{
    if ([self state] == ERPaletteClosed && [self palettePosition]%2 == 1) { // up or down
        if ([self palettePosition] == ERPalettePanelPositionDown) {
            [self setOpeningDirection:ERPaletteOutsideOpeningDirection];
        }else{
            [self setOpeningDirection:ERPaletteInsideOpeningDirection];
        }
        
        [self setState:ERPaletteOpened animate:YES];
    }
}

- (IBAction)openDown:(id)sender
{
    if ([self state] == ERPaletteClosed && [self palettePosition]%2 == 1) { // up or down
        if ([self palettePosition] == ERPalettePanelPositionDown) {
            [self setOpeningDirection:ERPaletteInsideOpeningDirection];
        }else{
            [self setOpeningDirection:ERPaletteOutsideOpeningDirection];
        }
        
        [self setState:ERPaletteOpened animate:YES];
    }
}

- (IBAction)openRight:(id)sender
{
    if ([self state] == ERPaletteClosed && [self palettePosition]%2 == 0) { // up or down
        if ([self palettePosition] == ERPalettePanelPositionRight) {
            [self setOpeningDirection:ERPaletteOutsideOpeningDirection];
        }else{
            [self setOpeningDirection:ERPaletteInsideOpeningDirection];
        }
        
        [self setState:ERPaletteOpened animate:YES];
    }
}

- (IBAction)openLeft:(id)sender
{
    if ([self state] == ERPaletteClosed && [self palettePosition]%2 == 0) { // up or down
        if ([self palettePosition] == ERPalettePanelPositionRight) {
            [self setOpeningDirection:ERPaletteInsideOpeningDirection];
        }else{
            [self setOpeningDirection:ERPaletteOutsideOpeningDirection];
        }
        
        [self setState:ERPaletteOpened animate:YES];
    }
}

- (NSView *)content
{
    return _content;
}

- (void)setContent:(NSView *)newContent
{
    [newContent retain];
    [_content removeFromSuperview];
    
    _content = newContent;
    [[self contentView] addSubview:_content];
    NSPoint frameOrigin = NSZeroPoint;
    
    [_content setFrameOrigin:frameOrigin];
}

- (NSRect)contentScreenFrame
{
    if ([self state] == ERPaletteClosed) {
        return NSZeroRect;
    }
    
    return [self convertRectToScreen:[self paletteContentFrame]];
}

- (NSSize)paletteContentSize
{
    NSSize size = [[self content] frame].size;
    size.height += [ERPaletteContentView paletteTitleHeight];

    return size;
}

- (NSRect)paletteContentFrame
{
    NSRect frame;
    
    NSPoint headerOrigin = [_titleView frame].origin;
    NSPoint contentOrigin = [_content frame].origin;
    
    frame.origin = NSMakePoint(MIN(headerOrigin.x, contentOrigin.x), MIN(headerOrigin.y, contentOrigin.y));
    frame.size = [self paletteContentSize];
        
    return frame;
}


- (NSRect)contentFilledRect
{
    NSRect frame;
    frame.size = [[self contentView] bounds].size;
    NSRect tabRect = [self tabRect];

    switch ([self effectiveHeaderPosition]) {
        case ERPalettePanelPositionDown:
            frame.origin = NSZeroPoint;
            frame.size.height -= tabRect.size.height;
            break;
        case ERPalettePanelPositionUp:
            frame.origin = NSMakePoint(0, NSMaxY(tabRect));
            frame.size.height -= tabRect.size.height;
            break;
            
        case ERPalettePanelPositionLeft:
            frame.origin = NSMakePoint(0, 0);
            frame.size.width -= tabRect.size.width;
            break;
            
        case ERPalettePanelPositionRight:
            frame.origin = NSMakePoint(NSMaxX(tabRect), 0);
            frame.size.width -= tabRect.size.width;
            break;
            
        default:
            break;
    }

    return frame;
}

- (NSSize)openedPaletteSize
{
    NSSize size = [[self content] frame].size;
    size.height += [ERPaletteContentView paletteTitleHeight];

    if ([self palettePosition] == ERPalettePanelPositionDown || [self palettePosition] == ERPalettePanelPositionUp) {
        size.height += [ERPalettePanel tabHeight];
    }else{
        size.width += [ERPalettePanel tabHeight];
    }
    
    return size;
}

- (NSSize)closedPaletteSize
{    
    return [self tabSize];
}

- (NSSize)tooltipPaletteSize
{
    NSSize size = [_titleView frame].size;
    
    if ([self palettePosition]%2 == 0) {
        size.height += [ERPalettePanel tabWidth];
        size.width += [ERPalettePanel tabHeight];
    }else{
        size.width += [ERPalettePanel tabWidth];
    }
    
    return size;
}

- (NSSize)paletteSize
{
    if ([self state] == ERPaletteClosed) {
        return [self closedPaletteSize];
    }else if ([self state] == ERPaletteOpened){
        return [self openedPaletteSize];
    }else if ([self state] == ERPaletteTooltip){
        return [self tooltipPaletteSize];
    }
    
    return NSZeroSize;
}

- (NSRect)headerRect
{
    return [(ERPaletteContentView *)[self contentView] headerRect];
}

- (NSSize)tabSize
{
    return [ERPalettePanel tabSizeForPanelPosition:[self palettePosition]];
}

- (NSRect)tabRect
{
    NSRect tabRect = NSZeroRect;

    tabRect.size = [self tabSize];

    switch ([self effectiveHeaderPosition]) {
        case ERPalettePanelPositionDown:
            tabRect.origin = NSMakePoint( 0, [self frame].size.height - tabRect.size.height);
            break;
            
        case ERPalettePanelPositionLeft:
            tabRect.origin = NSMakePoint( [self frame].size.width - tabRect.size.width ,[self frame].size.height - tabRect.size.height);
            break;
        case ERPalettePanelPositionUp:
            tabRect.origin = NSZeroPoint;
            break;
        case ERPalettePanelPositionRight:
            tabRect.origin = NSMakePoint( 0,[self frame].size.height - tabRect.size.height);
            break;
        default:
            break;
    }
    
    return tabRect;
}

- (void)setTabOrigin:(NSPoint)tabOrigin
{
    // compute the frame origin according to the new tab origin
    
    NSPoint newOrigin = tabOrigin;
    
    if ([self state] == ERPaletteOpened) {
        switch ([self effectiveHeaderPosition]) {
            case ERPalettePanelPositionDown:
                newOrigin.y -= [self paletteContentSize].height;
                break;
            case ERPalettePanelPositionUp:
                break;
                
            case ERPalettePanelPositionLeft:
                newOrigin.y = tabOrigin.y + [_tabButton frame].size.height - [self paletteContentSize].height;
                newOrigin.x -= [self paletteContentSize].width;
                break;
                
            case ERPalettePanelPositionRight:
                newOrigin.y = tabOrigin.y + [_tabButton frame].size.height - [self paletteContentSize].height;
                break;
                
            default:
                break;
        }
    }
    
    NSRect newFrame = [self frame];
    newFrame.origin = newOrigin;
    
    [self setFrame:newFrame display:YES];
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint
{
    _dragStartingPoint = screenPoint;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    switch(context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationNone;
            break;
            
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationMove;
            break;
    }
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    if (operation == NSDragOperationNone) {
        [self retain];
        [[self tabView] removePalette:self];
        
        // set the palette's origin
        NSPoint delta = screenPoint;
        delta.x -= _dragStartingPoint.x;
        delta.y -= _dragStartingPoint.y;
        
        NSPoint frameOrigin = [self frame].origin;
        frameOrigin.x += delta.x;
        frameOrigin.y += delta.y;
        
        [self setFrameOrigin:frameOrigin];

        if ([self state] == ERPaletteClosed) {
            [self setState:ERPaletteOpened];
        }
        
        // being a child window resets the window level
        [self setFloatingPanel:YES];
        
    }
}
@synthesize tabView = _tabView;

- (ERPaletteHolderView *)holder
{
    return [[self tabView] holder];
}

- (BOOL)isAttached
{
    return ([self tabView] != nil);
}

@synthesize locationInTabView;
- (NSComparisonResult)compareLocationInTabView:(ERPalettePanel *)palette
{
    CGFloat diff = [self locationInTabView] - [palette locationInTabView];
    if (diff < 0 ) {
        return NSOrderedAscending;
    }else if(diff > 0) {
        return NSOrderedDescending;
    }else{
        return NSOrderedSame;
    }
}

@synthesize icon;

- (void)invalidateShadow
{
    [super invalidateShadow];
    [self display];
}
@end
