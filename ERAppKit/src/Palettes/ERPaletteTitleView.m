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

@implementation ERPaletteTitleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        ERPaletteButton *closeButton = [[ERPaletteButton alloc] initWithFrame:NSMakeRect(NSMaxX([self bounds])-15, (frame.size.height-10.)/2., 10, 10)];
        [self addSubview:closeButton];
        [closeButton release];
        [closeButton setTarget:[self window]];
        [closeButton setAction:@selector(collapse:)];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSColor colorWithCalibratedWhite:0.3 alpha:0.9] set];
    [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:[self bounds].size.height/4. yRadius:[self bounds].size.height/4.] stroke];
    [[NSColor colorWithCalibratedWhite:0.5 alpha:0.9] set];
    [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:[self bounds].size.height/4. yRadius:[self bounds].size.height/4.] fill];

    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor selectedMenuItemTextColor], NSForegroundColorAttributeName,
                                [NSFont controlContentFontOfSize:11.0], NSFontAttributeName,
                                nil];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[[self window] title] attributes:attributes];
    
    NSPoint drawPoint = NSMakePoint(NSMinX([self bounds])+10, NSMinY([self bounds])+(NSHeight([self bounds])-[title size].height)/2.);
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


@end
