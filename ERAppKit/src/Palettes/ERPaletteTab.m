//
//  ERPaletteTab.m
//  ERAppKit
//
//  Created by Raphael Bost on 12/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteTab.h"

#import <ERAppKit/ERPalettePanel.h>
#import <ERAppKit/ERPaletteTabView.h>

@implementation ERPaletteTab

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self registerForDraggedTypes:[NSArray arrayWithObject:ERPalettePboardType]];
    }
    
    return self;
}

@synthesize palette;

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    if ([[self palette] state] == ERPaletteClosed) {
        [[NSColor colorWithCalibratedWhite:0.3 alpha:0.9] set];
    }else{
        [[NSColor colorWithCalibratedWhite:0.4 alpha:0.9] set];
    }
    
    [[NSBezierPath bezierPathWithOvalInRect:NSInsetRect([self bounds], 3, 3)] fill];
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
            
            NSRect draggingFrame = [self bounds];
            draggingFrame.origin.x -= delta.x;
            draggingFrame.origin.y -= delta.y;
            
            [dragItem setDraggingFrame:draggingFrame contents:[self draggingImage]];
            NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:[dragItem autorelease]] event:theEvent source:((ERPalettePanel *)[self window])];
            draggingSession.animatesToStartingPositionsOnCancelOrFail = NO;
            
            draggingSession.draggingFormation = NSDraggingFormationNone;
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 1) {
        [[self palette] toggleCollapse:self];
    }
}

// pass the dragging methods to the tab view so it can be handled properly

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        return [[(ERPalettePanel *)[self palette] tabView] draggingEntered:sender inPalette:(ERPalettePanel *)[self palette]];
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        return [[(ERPalettePanel *)[self palette] tabView] draggingUpdated:sender inPalette:(ERPalettePanel *)[self palette]];
    }
    return NSDragOperationNone;
}
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        [[(ERPalettePanel *)[self palette] tabView] draggingExited:sender inPalette:(ERPalettePanel *)[self palette]];
    }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        return [[(ERPalettePanel *)[self palette] tabView] performDragOperation:sender inPalette:(ERPalettePanel *)[self palette]];
    }
    
    return NO;
}


@end
