//
//  ERPaletteTitleView.m
//  ERAppKit
//
//  Created by Raphael Bost on 12/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteTitleView.h"

#import "ERPaletteButton.h"
#import <ERAppKit/ERPalettePanel.h>

#define ERHEADER_MOUSEOVER_INTERVAL 1.

@implementation ERPaletteTitleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _closeButton = [[ERPaletteButton alloc] initWithFrame:NSMakeRect(NSMaxX([self bounds])-15, (frame.size.height-10.)/2., 10, 10)];
        [self addSubview:_closeButton];
        [_closeButton release];
        [_closeButton setTarget:[self window]];
        [_closeButton setAction:@selector(collapse:)];
        
        
        _mouseOverArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                      options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp )
                                                        owner:self userInfo:nil];
        
        [self addTrackingArea:_mouseOverArea];

        _mouseOverTimer = [[ERTimer alloc] initWithTimeInterval:ERHEADER_MOUSEOVER_INTERVAL target:self selector:@selector(_timerCallBack) argument:nil];

    }
    
    return self;
}

- (void)dealloc
{
    [_mouseOverTimer stop];
    [_mouseOverTimer release];
    
    [super dealloc];
}
- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds],1,1) xRadius:[self bounds].size.height/4. yRadius:[self bounds].size.height/4.];
    NSGradient *backGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.3 alpha:0.9] endingColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.9]];
    
    [[NSColor colorWithCalibratedWhite:0.5 alpha:0.8] set];
//    [bp fill];
    [backGradient drawInBezierPath:bp angle:90];
    [[NSColor colorWithCalibratedWhite:0.1 alpha:0.8] set];
//    [bp stroke];
    
    
    
    

    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor selectedMenuItemTextColor], NSForegroundColorAttributeName,
                                [NSFont controlContentFontOfSize:11.0], NSFontAttributeName,
                                nil];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[[self window] title] attributes:attributes];
    
    NSPoint drawPoint = NSMakePoint(NSMinX([self bounds])+10, NSMinY([self bounds])+(NSHeight([self bounds])-[title size].height)/2.);
    
    if ([(ERPalettePanel *)[self window] effectiveHeaderPosition] == ERPalettePanelPositionLeft) {
        drawPoint.x = NSMaxX([self bounds]) - [title size].width - drawPoint.x;
    }
    [title drawAtPoint:drawPoint];
    [title release];
}


- (NSImage *)draggingImage
{
    NSImage *image = [[NSImage alloc] initWithSize:[self frame].size];
    [image lockFocus];
    [self drawRect:[self bounds]];
    [image unlockFocus];
    
    return [image autorelease];
}


- (void)mouseDown:(NSEvent *)theEvent
{
    _draggingStartPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    ERPalettePanel *window = (ERPalettePanel *)[self window];

    if ([window isAttached]) {
        if (_draggingStartPoint.x != NSNotFound) {
            NSPoint screenLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            NSPoint delta = _draggingStartPoint;
            delta.x -= screenLocation.x ;
            delta.y -= screenLocation.y ;
            
            if (sqrt(delta.x*delta.x + delta.y*delta.y) > 10) {
                
                NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
                [pbItem setString:NSStringFromSize([self frame].size) forType:ERPalettePboardType];
                NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
                [pbItem release];
                
                [dragItem setDraggingFrame:[self bounds] contents:[self draggingImage]];
                NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:[dragItem autorelease]] event:theEvent source:window];
                draggingSession.animatesToStartingPositionsOnCancelOrFail = NO;
                
                draggingSession.draggingFormation = NSDraggingFormationNone;

            }
        }
    }else{
        NSPoint startLocation =  [window convertBaseToScreen:[theEvent locationInWindow]];
        
        if ([window isMovableByWindowBackground]) {
            [super mouseDragged: theEvent];
            return;
        }
        
        NSPoint origin = [window frame].origin;
        while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]) && ([theEvent type] != NSLeftMouseUp)) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                NSPoint currentLocation = [window convertBaseToScreen:[theEvent locationInWindow]];
                origin.x += currentLocation.x - startLocation.x;
                origin.y += currentLocation.y - startLocation.y;
                [window setFrameOrigin:origin];
                startLocation = currentLocation;
            [pool release];
        }

    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2) {
        [(ERPalettePanel *)[self window] toggleCollapse:self];
    }
    _draggingStartPoint = NSMakePoint(NSNotFound, NSNotFound);
    
}

- (void)updateCloseButtonPosition
{
    if ([(ERPalettePanel *)[self window] effectiveHeaderPosition] == ERPalettePanelPositionLeft) {
        [_closeButton setFrameOrigin:NSMakePoint(5, ([self bounds].size.height-10.)/2.)];
    }else{
        [_closeButton setFrameOrigin:NSMakePoint(NSMaxX([self bounds])-15, ([self bounds].size.height-10.)/2.)];
    }
}


- (void)mouseEntered:(NSEvent *)theEvent
{
    if ([(ERPalettePanel *)[self window] state] == ERPaletteTooltip) {
        [_mouseOverTimer start];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [_mouseOverTimer stop];
    
    NSPoint location = [theEvent locationInWindow];
    ERPalettePanel *palette = (ERPalettePanel *)[self window];
    if ([palette state] == ERPaletteTooltip) {
        if (!NSPointInRect(location, [palette tabRect])) { // the mouse is now outside of the palette
            [palette setState:ERPaletteClosed animate:YES];
        }
    }
}

- (void)_timerCallBack
{
    [(ERPalettePanel *)[self window] setState:ERPaletteOpened animate:YES];
}

@end
