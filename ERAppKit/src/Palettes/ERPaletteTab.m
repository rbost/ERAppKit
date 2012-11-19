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

#import <ERAppKit/NSBezierPath+ERAppKit.h>

#define TAB_ROUNDED_RADIUS 5.

@implementation ERPaletteTab
+ (NSBezierPath *)openedTabCorner
{
    NSBezierPath *bp = [NSBezierPath bezierPath];
    NSPoint corner = NSZeroPoint;
    CGFloat radius = TAB_ROUNDED_RADIUS;
    [bp moveToPoint:NSMakePoint(corner.x, corner.y+radius)];
    [bp lineToPoint:corner];
    [bp lineToPoint:NSMakePoint(corner.x-radius, corner.y)];
    [bp appendBezierPathWithArcWithCenter:NSMakePoint(corner.x-radius, corner.y+radius) radius:radius startAngle:-90 endAngle:0 clockwise:NO];
    [bp closePath];

    return bp;
}
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
    [[NSColor redColor] set];
//    [NSBezierPath fillRect:dirtyRect];
    
    // Drawing code here.
    if ([[self palette] state] == ERPaletteClosed) {
        [[NSColor colorWithCalibratedWhite:0.4 alpha:0.9] set];
    }else{
        [[NSColor colorWithCalibratedWhite:0.1 alpha:0.9] set];
    }

    NSRect bounds ;
    if ([[self palette] palettePosition] == ERPalettePanelPositionUp || [[self palette] palettePosition] == ERPalettePanelPositionDown) {
        bounds = NSInsetRect([self bounds],TAB_ROUNDED_RADIUS,0.);
        // let some space for the palette rounded corner
        bounds.origin.x += TAB_ROUNDED_RADIUS;
        bounds.size.width -= TAB_ROUNDED_RADIUS;
        
        if ([[self palette] state] == ERPaletteClosed) {
            bounds = NSInsetRect(bounds, 0, 2.);
        }else{
            bounds.size.height -= 2.;
            
            if ([[self palette] effectiveHeaderPosition] == ERPalettePanelPositionDown) {
                bounds.origin.y += 2.;
            }
        }
    }else{
        bounds = NSInsetRect([self bounds],0.,TAB_ROUNDED_RADIUS);
        bounds.origin.y += TAB_ROUNDED_RADIUS;
        bounds.size.height -= TAB_ROUNDED_RADIUS;
        
        if ([[self palette] state] == ERPaletteClosed) {
            bounds = NSInsetRect(bounds, 2.,0);
        }else{
            bounds.size.width -= 2.;
            
            if ([[self palette] effectiveHeaderPosition] ==  ERPalettePanelPositionRight) {
                bounds.origin.x += 2.;
            }
        }
    }

    int corners;
    
    switch ([[self palette] effectiveHeaderPosition]) {
        case ERPalettePanelPositionUp:
            corners = ERUpperRightCorner | ERUpperLeftCorner;
            break;
            
        case ERPalettePanelPositionDown:
            corners = ERLowerRightCorner | ERLowerLeftCorner;
            break;
            
        case ERPalettePanelPositionLeft:
            corners = ERUpperRightCorner | ERLowerRightCorner;
            break;
            
        case ERPalettePanelPositionRight:
            corners = ERLowerLeftCorner | ERUpperLeftCorner;
            break;
            
        default:
            corners = ERNoneCorner;
            break;
    }
    
    if ([[self palette] state] == ERPaletteClosed) {
        corners = ERAllCorners;
    }
    
    NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:bounds radius:TAB_ROUNDED_RADIUS corners:corners];

    [bp fill];
    
    if ([[self palette] state] == ERPaletteOpened) {
        // draw inverted corners
        NSBezierPath *corner1, *corner2;
        NSAffineTransform *at1 = [NSAffineTransform transform], *at2 = [NSAffineTransform transform];
        
        switch ([[self palette] effectiveHeaderPosition]) {
            case ERPalettePanelPositionUp:
                [at1 translateXBy:NSMinX(bounds) yBy:NSMinY(bounds)]; 
                [at2 translateXBy:NSMaxX(bounds) yBy:NSMinY(bounds)]; [at2 scaleXBy:-1 yBy:1]; 
                break;
                
            case ERPalettePanelPositionDown:
                [at1 translateXBy:NSMinX(bounds) yBy:NSMaxY(bounds)]; [at1 scaleXBy:1 yBy:-1];
                [at2 translateXBy:NSMaxX(bounds) yBy:NSMaxY(bounds)]; [at2 scaleXBy:-1 yBy:-1];
                break;
                
            case ERPalettePanelPositionLeft:
                [at1 translateXBy:NSMinX(bounds) yBy:NSMinY(bounds)]; [at1 scaleXBy:-1 yBy:-1];
                [at2 translateXBy:NSMinX(bounds) yBy:NSMaxY(bounds)]; [at2 scaleXBy:-1 yBy:1];

                break;
                
            case ERPalettePanelPositionRight:
                [at1 translateXBy:NSMaxX(bounds) yBy:NSMinY(bounds)]; [at1 scaleXBy:1 yBy:-1];
                [at2 translateXBy:NSMaxX(bounds) yBy:NSMaxY(bounds)]; [at2 scaleXBy:1 yBy:1];

                break;
                
            default:
                break;
        }
        
        corner1 = [ERPaletteTab openedTabCorner]; [corner1 transformUsingAffineTransform:at1];
        corner2 = [ERPaletteTab openedTabCorner]; [corner2 transformUsingAffineTransform:at2];
        
        [corner1 fill];
        [corner2 fill];
    }
}

- (NSImage *)draggingImage
{
    NSImage *image = [[NSImage alloc] initWithSize:[self frame].size];
    [image setFlipped:YES];
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
            draggingFrame.origin = screenLocation;
            draggingFrame.origin.x -= draggingFrame.size.width/2.;
            draggingFrame.origin.y -= draggingFrame.size.height/2.;
            
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
