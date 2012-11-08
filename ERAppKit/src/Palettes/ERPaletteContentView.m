//
//  ERPaletteContentView.m
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteContentView.h"

#import <ERAppKit/ERPalettePanel.h>

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
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSColor blackColor] set];
    [NSBezierPath fillRect:dirtyRect];

    [self drawTitleHeader];
    [self drawTitleString];
}

- (void)drawTitleHeader
{
    [[NSColor greenColor] set];
    [NSBezierPath fillRect:[self headerRect]];
}

- (void)drawTitleString
{
    if (![[self window] title]) {
        return;
    }
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:[[self window] title] attributes:nil];
    
//    [attributedTitle drawAtPoint:[self headerRect].origin];
    NSAffineTransform *t = [NSAffineTransform transform];
    NSRect windowFrame = [[self window] frame];
    NSRect headerRect = [self headerRect];
    switch ([(ERPalettePanel *)[self window] palettePosition]) {
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
    [attributedTitle drawAtPoint:NSZeroPoint];
    
    [NSGraphicsContext restoreGraphicsState];
}
- (NSRect)headerRect
{
    NSRect headerRect = NSZeroRect;
    
    switch ([(ERPalettePanel *)[self window] palettePosition]) {
        case ERPalettePanelPositionDown:
            headerRect = NSMakeRect(0, [self bounds].size.height -__paletteTitleSize, [self bounds].size.width, __paletteTitleSize);
            break;
            
        case ERPalettePanelPositionLeft:
            headerRect = NSMakeRect([self bounds].size.width-__paletteTitleSize, 0, __paletteTitleSize, [self bounds].size.height);
            break;
        case ERPalettePanelPositionUp:
            headerRect = NSMakeRect(0, 0, [self bounds].size.width, __paletteTitleSize);
            break;
        case ERPalettePanelPositionRight:
            headerRect = NSMakeRect(0, 0, __paletteTitleSize, [self bounds].size.height);
            break;
        default:
            break;
    }
    
    return headerRect;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], [self headerRect])) {
//        _draggingStartPoint = [NSEvent mouseLocation];//[self convertPoint:[theEvent locationInWindow] fromView:nil];
//        _oldFrameOrigin = [[self window] frame].origin;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_draggingStartPoint.x != NSNotFound) {
        NSPoint location = [NSEvent mouseLocation];//[self convertPoint:[theEvent locationInWindow] fromView:nil];
    
        NSPoint origin = _oldFrameOrigin;
        origin.x += location.x - _draggingStartPoint.x;
        origin.y += location.y - _draggingStartPoint.y;
     
        [[self window] setFrameOrigin:origin];
        _didDrag = YES;
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

@end
