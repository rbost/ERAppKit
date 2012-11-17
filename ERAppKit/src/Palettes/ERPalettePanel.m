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

@implementation ERPalettePanel
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
        contentRect.size.height += [ERPaletteContentView paletteTitleSize];
    }else{
        contentRect.size.width += [ERPaletteContentView paletteTitleSize];
    }

    self = [self initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];

    [self setContent:content];
    
    _titleView = [[ERPaletteTitleView alloc] initWithFrame:[[self contentView] headerRect]];
    [[self contentView] addSubview:_titleView];
    [_titleView release];
    
    _tabButton = [[ERPaletteTab alloc] initWithFrame:[[self contentView] tabRect]];
    [[self contentView] addSubview:_tabButton];
    [_tabButton release];
    [_tabButton setPalette:self];

    [self updateFrameSizeAndContentPlacement];
    [self updateAutoresizingMask];
    
    [self setFloatingPanel:YES];
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
    // update the content autosizing mask with respect to the new position of the palette
    [self updateFrameSizeAndContentPlacement];
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
    [self updateFrameSizeAndContentPlacement];
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
            frame.origin.y += [ERPaletteContentView paletteTitleSize];
            break;
        case ERPalettePanelPositionDown:
            frame.origin.y -= frame.size.height;
            break;
        case ERPalettePanelPositionRight:
            frame.origin.x += [ERPaletteContentView paletteTitleSize];
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

- (void)updateFrameSizeAndContentPlacement
{
    NSRect frame = [self frame];
    
    frame.size = [self paletteSize];
    [self setFrame:frame display:YES];

    NSPoint frameOrigin = NSZeroPoint;
    ERPalettePanelPosition pos = [self effectiveHeaderPosition];
    
    if (pos == ERPalettePanelPositionUp) {
        frameOrigin.y = 2*[ERPaletteContentView paletteTitleSize];
    }else if(pos == ERPalettePanelPositionDown) {
        frameOrigin.y = [self paletteSize].height - 2*[ERPaletteContentView paletteTitleSize] - [[self content] frame].size.height;
    }else if (pos == ERPalettePanelPositionRight) {
        frameOrigin.x = [ERPaletteContentView paletteTitleSize];
        frameOrigin.y = [self paletteSize].height - [ERPaletteContentView paletteTitleSize] - [[self content] frame].size.height;

    }else if (pos == ERPalettePanelPositionLeft) {
        frameOrigin.x = [self paletteSize].width - [ERPaletteContentView paletteTitleSize] - [[self content] frame].size.width;
        frameOrigin.y = [self paletteSize].height - [ERPaletteContentView paletteTitleSize] - [[self content] frame].size.height;

    }
    
    [_content setFrameOrigin:frameOrigin];
    
    NSRect tabRect = [[self contentView] tabRect];
    if (pos == ERPalettePanelPositionUp) {
        frameOrigin = NSMakePoint(NSMinX(tabRect), NSMaxY(tabRect));
    }else if(pos == ERPalettePanelPositionDown) {
        frameOrigin = NSMakePoint(NSMinX(tabRect), NSMinY(tabRect)-[_titleView frame].size.height);
    }else if (pos == ERPalettePanelPositionRight) {
        frameOrigin = NSMakePoint(NSMaxX(tabRect), NSMinY(tabRect));
    }else if (pos == ERPalettePanelPositionLeft) {
        frameOrigin = NSMakePoint(NSMinX(tabRect)-[_titleView frame].size.width, NSMinY(tabRect));
    }

    [_titleView setFrameOrigin:frameOrigin];
    [_tabButton setFrameOrigin:[[self contentView] tabRect].origin];
    
    NSRect hFrame = [self headerRect];
    NSPoint corner = hFrame.origin;
    
    if (pos == ERPalettePanelPositionDown || pos == ERPalettePanelPositionUp) {
        corner.x += hFrame.size.width - 30 ;
    }else{
    }
    NSPoint buttonLocation = NSMakePoint(corner.x, corner.y + 5);
    
    [_button1 setFrameOrigin:buttonLocation];
    [_button2 setFrameOrigin:NSMakePoint(buttonLocation.x+15, buttonLocation.y)];
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
    
    if (state == ERPaletteClosed) {
        NSRect tabFrame = [(ERPaletteContentView *)[self contentView] tabRect];
        tabFrame = [[self contentView] convertRect:tabFrame toView:nil];
        tabFrame = [self convertRectToScreen:tabFrame];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidCloseNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:tabFrame] forKey:ERPaletteNewFrameKey]];
        if (animate) {
            [[self animator] setFrame:tabFrame display:YES];
        }else{
            [self setFrame:tabFrame display:YES];
        }
    }else{
        NSSize contentSize = [[self content] frame].size;
        NSRect newFrame,tabFrame;
        newFrame.size = [self openedPaletteSize];
        
        tabFrame = [[self contentView] tabRect];
        newFrame.origin = tabFrame.origin;
        
        ERPalettePanelPosition pos = [self effectiveHeaderPosition];
        
        switch (pos) {
            case ERPalettePanelPositionLeft:
                newFrame.origin.x -= contentSize.width;
                newFrame.origin.y -= contentSize.height;
                break;

            case ERPalettePanelPositionRight:
                newFrame.origin.y -= contentSize.height;
                break;

            case ERPalettePanelPositionUp:
                break;

            case ERPalettePanelPositionDown:
                newFrame.origin.y -= contentSize.height + [[self contentView] headerRect].size.height;
                break;

            default:
                break;
        }
        newFrame = [[self contentView] convertRect:newFrame toView:nil];
        newFrame = [self convertRectToScreen:newFrame];

//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRect:newFrame],ERPaletteNewFrameKey,
//                                  nil]
        NSRect contentFrame = [self contentFrameForOpeningDirection:[self openingDirection]];
        [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidOpenNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:contentFrame] forKey:ERPaletteNewFrameKey]];
        
        if (animate) {
            [[self animator] setFrame:newFrame display:YES];
        }else{
            [self setFrame:newFrame display:YES];
        }
        

    }
    
    _state = state;
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
    if (_state != ERPaletteClosed) {
        [self collapse:sender];
    }else{
        [self openInBestDirection:sender];
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
    
    if ([self palettePosition] == ERPalettePanelPositionUp) {
        frameOrigin.y = [ERPaletteContentView paletteTitleSize];
    }else if ([self palettePosition] == ERPalettePanelPositionRight) {
        frameOrigin.x = [ERPaletteContentView paletteTitleSize];
    }
    
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
    size.height += [ERPaletteContentView paletteTitleSize];

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

- (NSSize)openedPaletteSize
{
    NSSize size = [[self content] frame].size;
    size.height += [ERPaletteContentView paletteTitleSize];

    if ([self palettePosition] == ERPalettePanelPositionDown || [self palettePosition] == ERPalettePanelPositionUp) {
        size.height += [ERPaletteContentView paletteTitleSize];
    }else{
        size.width += [ERPaletteContentView paletteTitleSize];
    }
    
    return size;
}

- (NSSize)closedPaletteSize
{    
    return NSMakeSize([ERPaletteContentView paletteTitleSize], [ERPaletteContentView paletteTitleSize]);
}

- (NSSize)paletteSize
{
    if ([self state] == ERPaletteClosed) {
        return [self closedPaletteSize];
    }else{
        return [self openedPaletteSize];
    }
}

- (NSRect)headerRect
{
    return [(ERPaletteContentView *)[self contentView] headerRect];
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
                newOrigin.y -= [[self content] frame].size.height;
                newOrigin.x -= [self paletteContentSize].width;
                break;
                
            case ERPalettePanelPositionRight:
                newOrigin.y -= [[self content] frame].size.height;
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
@end
