//
//  ERPaletteContentView.m
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteContentView.h"

#import <ERAppKit/ERPalettePanel.h>
#import <ERAppKit/ERPaletteTabView.h>

static CGFloat __paletteTitleSize = 20.;

@implementation ERPaletteContentView

+ (CGFloat)paletteTitleSize
{
    return __paletteTitleSize;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _draggingStartPoint = NSMakePoint(NSNotFound, NSNotFound);
        
        [self registerForDraggedTypes:[NSArray arrayWithObject:ERPalettePboardType]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
//    [[NSColor blackColor] set];
//    [NSBezierPath fillRect:dirtyRect];

    NSAffineTransform *t = [NSAffineTransform transform];
    NSRect windowFrame = [[self window] frame];
    NSRect headerRect = [self headerRect];
    switch ([(ERPalettePanel *)[self window] effectiveHeaderPosition]) {
        case ERPalettePanelPositionDown:
            [t translateXBy:0 yBy:windowFrame.size.height-headerRect.size.height];
            break;
            
        case ERPalettePanelPositionLeft:
            [t translateXBy:windowFrame.size.width-headerRect.size.width yBy:headerRect.size.height];
            [t rotateByDegrees:-90];
            break;
        case ERPalettePanelPositionUp:
            break;
        case ERPalettePanelPositionRight:
            [t translateXBy:0 yBy:headerRect.size.height];
            [t rotateByDegrees:-90];
            break;
        default:
            break;
    }
    
    [NSGraphicsContext saveGraphicsState];
    [t concat];
    [self drawHeader];
    
    [NSGraphicsContext restoreGraphicsState];

}

- (void)drawHeader
{
    NSRect headerFrame = NSZeroRect;
    
    ERPalettePanelPosition pos = [(ERPalettePanel *)[self window] palettePosition];
    pos = [(ERPalettePanel *)[self window] effectiveHeaderPosition];
    ERPalettePanel *window = (ERPalettePanel *)[self window];
    if (pos == ERPalettePanelPositionUp || pos == ERPalettePanelPositionDown) {
        headerFrame.size = NSMakeSize([[window content] frame].size.width, [ERPaletteContentView paletteTitleSize]);
    }else{
        headerFrame.size = NSMakeSize([[window content] frame].size.height,[ERPaletteContentView paletteTitleSize]);
    }
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:[[self window] title] attributes:nil];

    [NSGraphicsContext saveGraphicsState];
    
    [[NSColor greenColor] set];
    [NSBezierPath fillRect:headerFrame];
    
    NSSize titleSize = [attributedTitle size];
    [attributedTitle drawAtPoint:NSMakePoint(10, ([ERPaletteContentView paletteTitleSize] - titleSize.height)/2.)];

    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawDragZone
{
    NSBezierPath *bars = [NSBezierPath bezierPath];
    [bars moveToPoint:NSMakePoint(5, 5)];
    [bars lineToPoint:NSMakePoint(5, [ERPaletteContentView paletteTitleSize]-5)];
    [bars moveToPoint:NSMakePoint(10, 5)];
    [bars lineToPoint:NSMakePoint(10, [ERPaletteContentView paletteTitleSize]-5)];
    [bars moveToPoint:NSMakePoint(15, 5)];
    [bars lineToPoint:NSMakePoint(15, [ERPaletteContentView paletteTitleSize]-5)];
    
    [[NSColor blackColor] set];
    [bars stroke];    
}

- (NSRect)headerRect
{
    NSRect headerRect = NSZeroRect;
    ERPalettePanel *window = (ERPalettePanel *)[self window];

    switch ([window effectiveHeaderPosition]) {
        case ERPalettePanelPositionDown:
            headerRect = NSMakeRect(0, [window frame].size.height -__paletteTitleSize, [[window content] bounds].size.width, __paletteTitleSize);
            break;
            
        case ERPalettePanelPositionLeft:
            headerRect = NSMakeRect([window frame].size.width-__paletteTitleSize, 0, __paletteTitleSize, [[window content] bounds].size.height);
            break;
        case ERPalettePanelPositionUp:
            headerRect = NSMakeRect(0, 0, [[window content] bounds].size.width, __paletteTitleSize);
            break;
        case ERPalettePanelPositionRight:
            headerRect = NSMakeRect(0, 0, __paletteTitleSize, [[window content] bounds].size.height);
            break;
        default:
            break;
    }
    
    return headerRect;
}

- (NSImage *)headerImage
{
    NSSize headerSize = NSZeroSize;
    
    ERPalettePanelPosition pos = [(ERPalettePanel *)[self window] palettePosition];
    if (pos == ERPalettePanelPositionUp || pos == ERPalettePanelPositionDown) {
        headerSize = NSMakeSize([self frame].size.width, [ERPaletteContentView paletteTitleSize]);
    }else{
        headerSize = NSMakeSize([ERPaletteContentView paletteTitleSize],[self frame].size.height);
    }

    NSImage *image = [[NSImage alloc] initWithSize:headerSize];
    
    NSAffineTransform *t = [NSAffineTransform transform];

    NSRect headerRect = [self headerRect];
    switch ([(ERPalettePanel *)[self window] palettePosition]) {
        case ERPalettePanelPositionLeft:
            [t translateXBy:0 yBy:headerRect.size.height];
            [t rotateByDegrees:-90];
            break;
        case ERPalettePanelPositionRight:
            [t translateXBy:0 yBy:headerRect.size.height];
            [t rotateByDegrees:-90];
            break;
        default:
            break;
    }

    [image lockFocus];
    [t concat];

    [self drawHeader];
    [image unlockFocus];
    
    
    return [image autorelease];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], [self headerRect])) {
        _draggingStartPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_draggingStartPoint.x != NSNotFound) {
        NSPoint screenLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
        NSPoint delta = _draggingStartPoint;
        delta.x -= screenLocation.x ;
        delta.y -= screenLocation.y ;
     
        if (sqrt(delta.x*delta.x + delta.y*delta.y) > 10) {

            NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSDragPboard];
            [pBoard declareTypes:[NSArray arrayWithObject:ERPalettePboardType] owner:[self window]];
            [pBoard setString:NSStringFromSize([self headerRect].size) forType:ERPalettePboardType];
            
            NSPoint headerRectOrigin = [self headerRect].origin;
            [self dragImage:[self headerImage] at:NSMakePoint(headerRectOrigin.x - delta.x, headerRectOrigin.y - delta.y) offset:NSZeroSize event:theEvent pasteboard:pBoard source:[self window] slideBack:YES];
            _didDrag = YES;
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2 && NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], [self headerRect])) {
        [(ERPalettePanel *)[self window] toggleCollapse:self];
    }
    _draggingStartPoint = NSMakePoint(NSNotFound, NSNotFound);
    _didDrag = NO;
}

// pass the dragging methods to the tab view so it can be handled properly

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        return [[(ERPalettePanel *)[self window] tabView] draggingEntered:sender inPalette:(ERPalettePanel *)[self window]];
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        return [[(ERPalettePanel *)[self window] tabView] draggingUpdated:sender inPalette:(ERPalettePanel *)[self window]];
    }
    return NSDragOperationNone;
}
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        [[(ERPalettePanel *)[self window] tabView] draggingExited:sender inPalette:(ERPalettePanel *)[self window]];
    }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        return [[(ERPalettePanel *)[self window] tabView] performDragOperation:sender inPalette:(ERPalettePanel *)[self window]];
    }

    return NO;
}

@end
