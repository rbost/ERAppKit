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

//    [self drawTitleHeader];
//    [self drawTitleString];

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
    [self drawHeader];
    
    [NSGraphicsContext restoreGraphicsState];

}

- (void)drawHeader
{
    NSRect headerFrame = NSZeroRect;
    
    ERPalettePanelPosition pos = [(ERPalettePanel *)[self window] palettePosition];
    if (pos == ERPalettePanelPositionUp || pos == ERPalettePanelPositionDown) {
        headerFrame.size = NSMakeSize([self frame].size.width, [ERPaletteContentView paletteTitleSize]);
    }else{
        headerFrame.size = NSMakeSize([ERPaletteContentView paletteTitleSize],[self frame].size.height);
    }
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:[[self window] title] attributes:nil];

    [NSGraphicsContext saveGraphicsState];
    
    [[NSColor greenColor] set];
    [NSBezierPath fillRect:headerFrame];
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
    
    [image lockFocus];
    [self drawHeader];
    [image unlockFocus];
    
    
    return [image autorelease];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], [self headerRect])) {
        _draggingStartPoint = [NSEvent mouseLocation];//[self convertPoint:[theEvent locationInWindow] fromView:nil];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_draggingStartPoint.x != NSNotFound) {
        NSPoint screenLocation = [NSEvent mouseLocation];//[self convertPoint:[theEvent locationInWindow] fromView:nil];
//        NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
        NSPoint delta = _oldFrameOrigin;
        delta.x -= screenLocation.x ;
        delta.y -= screenLocation.y ;
     
        if (sqrt(delta.x*delta.x + delta.y*delta.y) > 10) {
            NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSDragPboard];
            [pBoard declareTypes:[NSArray arrayWithObject:ERPalettePboardType] owner:[self window]];
            [pBoard setString:NSStringFromSize([self headerRect].size) forType:ERPalettePboardType];
            
            [self dragImage:[self headerImage] at:NSZeroPoint offset:NSZeroSize event:theEvent pasteboard:pBoard source:[self window] slideBack:YES];
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

@end
