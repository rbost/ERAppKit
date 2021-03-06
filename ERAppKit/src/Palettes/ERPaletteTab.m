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
#import <ERAppKit/ERGeometry.h>

#import <ERAppKit/ERPaletteOpenPopup.h>

#define TAB_ROUNDED_RADIUS 5.

#define ERTAB_MOUSEOVER_INTERVAL 1.

@interface ERPaletteTab ()
- (void)_getDrawingRectsTabRect:(NSRect *)tabRectPtr bounds:(NSRect *)boundsPtr;
@end

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
        
        NSRect bounds;
        [self _getDrawingRectsTabRect:NULL bounds:&bounds];
        _mouseOverArea = [[NSTrackingArea alloc] initWithRect:bounds
                                                      options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp )
                                                        owner:self userInfo:nil];
        
        [self addTrackingArea:_mouseOverArea];
        
        
        _mouseOverTimer = [[ERTimer alloc] initWithTimeInterval:ERTAB_MOUSEOVER_INTERVAL target:self selector:@selector(_timerCallBack) argument:nil];

    }
    
    return self;
}

- (void)dealloc
{
    [_mouseOverArea release];
    [_mouseOverTimer stop];
    [_mouseOverTimer release];
    
    [super dealloc];
}

@synthesize palette;

- (void)_getDrawingRectsTabRect:(NSRect *)tabRectPtr bounds:(NSRect *)boundsPtr
{
    NSRect bounds, tabRect;
    if ([[self palette] palettePosition] == ERPalettePanelPositionUp || [[self palette] palettePosition] == ERPalettePanelPositionDown) {
        bounds = NSInsetRect([self bounds],TAB_ROUNDED_RADIUS,0.);
        // let some space for the palette rounded corner
        bounds.origin.x += TAB_ROUNDED_RADIUS;
        bounds.size.width -= TAB_ROUNDED_RADIUS;
        
        tabRect = bounds;
        if ([[self palette] state] == ERPaletteClosed) {
            tabRect = NSInsetRect(tabRect, 0, 2.);
        }else{
            tabRect.size.height -= 2.;
            
            if ([[self palette] effectiveHeaderPosition] == ERPalettePanelPositionDown) {
                tabRect.origin.y += 2.;
            }
        }
    }else{
        bounds = NSInsetRect([self bounds],0.,TAB_ROUNDED_RADIUS);
        bounds.origin.y += TAB_ROUNDED_RADIUS;
        bounds.size.height -= TAB_ROUNDED_RADIUS;
        
        tabRect = bounds;
        if ([[self palette] state] == ERPaletteClosed) {
            tabRect = NSInsetRect(tabRect, 2.,0);
        }else{
            tabRect.size.width -= 2.;
            
            if ([[self palette] effectiveHeaderPosition] ==  ERPalettePanelPositionRight) {
                tabRect.origin.x += 2.;
            }
        }
    }
    
    if (tabRectPtr != NULL) {
        *tabRectPtr = tabRect;
    }
    
    if (boundsPtr != NULL) {
        *boundsPtr = bounds;
    }
}

- (NSRect)drawnButtonRect
{
    NSRect bounds;
    [self _getDrawingRectsTabRect:NULL bounds:&bounds];
    
    return bounds;
}

- (void)drawTab
{
    NSRect bounds, tabRect;
    [self _getDrawingRectsTabRect:&tabRect bounds:&bounds];
    NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:tabRect xRadius:TAB_ROUNDED_RADIUS yRadius:TAB_ROUNDED_RADIUS];
    
    [[NSColor colorWithCalibratedWhite:0.4 alpha:0.9] set];

    [bp fill];
    
    NSImage *icon = [[self palette] icon];
    NSRect iconRect;
    iconRect.size = [icon size];
    iconRect.origin = bounds.origin;
    
    iconRect.origin.x += 0.5*(bounds.size.width - iconRect.size.width); iconRect.origin.x = floor(iconRect.origin.x);
    iconRect.origin.y += 0.5*(bounds.size.height - iconRect.size.height);iconRect.origin.y = floor(iconRect.origin.y);
    
    [icon drawInRect:iconRect fromRect:NSMakeRect(0, 0, [icon size].width, [icon size].height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
}

- (void)drawOpenTab
{
    NSRect bounds, tabRect;
    [self _getDrawingRectsTabRect:&tabRect bounds:&bounds];
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
    
    NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:tabRect radius:TAB_ROUNDED_RADIUS corners:corners];
    
    [[NSColor colorWithCalibratedWhite:0.1 alpha:0.95] set];

    [bp fill];
    
    if ([[self palette] state] == ERPaletteOpened) {
        // draw inverted corners
        NSBezierPath *corner1, *corner2;
        NSAffineTransform *at1 = [NSAffineTransform transform], *at2 = [NSAffineTransform transform];
        
        switch ([[self palette] effectiveHeaderPosition]) {
            case ERPalettePanelPositionUp:
                [at1 translateXBy:NSMinX(tabRect) yBy:NSMinY(tabRect)];
                [at2 translateXBy:NSMaxX(tabRect) yBy:NSMinY(tabRect)]; [at2 scaleXBy:-1 yBy:1];
                break;
                
            case ERPalettePanelPositionDown:
                [at1 translateXBy:NSMinX(tabRect) yBy:NSMaxY(tabRect)]; [at1 scaleXBy:1 yBy:-1];
                [at2 translateXBy:NSMaxX(tabRect) yBy:NSMaxY(tabRect)]; [at2 scaleXBy:-1 yBy:-1];
                break;
                
            case ERPalettePanelPositionLeft:
                [at1 translateXBy:NSMinX(tabRect) yBy:NSMinY(tabRect)]; [at1 scaleXBy:-1 yBy:-1];
                [at2 translateXBy:NSMinX(tabRect) yBy:NSMaxY(tabRect)]; [at2 scaleXBy:-1 yBy:1];
                
                break;
                
            case ERPalettePanelPositionRight:
                [at1 translateXBy:NSMaxX(tabRect) yBy:NSMinY(tabRect)]; [at1 scaleXBy:1 yBy:-1];
                [at2 translateXBy:NSMaxX(tabRect) yBy:NSMaxY(tabRect)]; [at2 scaleXBy:1 yBy:1];
                
                break;
                
            default:
                break;
        }
        
        corner1 = [ERPaletteTab openedTabCorner]; [corner1 transformUsingAffineTransform:at1];
        corner2 = [ERPaletteTab openedTabCorner]; [corner2 transformUsingAffineTransform:at2];
        
        [corner1 fill];
        [corner2 fill];
    }

    NSImage *icon = [[self palette] icon];
    NSRect iconRect;
    iconRect.size = [icon size];
    iconRect.origin = bounds.origin;
    
    iconRect.origin.x += 0.5*(bounds.size.width - iconRect.size.width); iconRect.origin.x = floor(iconRect.origin.x);
    iconRect.origin.y += 0.5*(bounds.size.height - iconRect.size.height);iconRect.origin.y = floor(iconRect.origin.y);
    
    [icon drawInRect:iconRect fromRect:NSMakeRect(0, 0, [icon size].width, [icon size].height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];

}

- (void)drawRect:(NSRect)dirtyRect
{
    if ([[self palette] state] == ERPaletteClosed) {
        [self drawTab];
    }else{
        [self drawOpenTab];
    }
}

- (NSImage *)draggingImage
{
    NSImage *image = [[NSImage alloc] initWithSize:[self frame].size];
    [image lockFocusFlipped:YES];
    [self drawTab];
    [image unlockFocus];
    
    return [image autorelease];
}

- (void)mouseDown:(NSEvent *)theEvent
{
   _draggingStartPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [_mouseOverTimer stop];
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
    [_mouseOverTimer stop];
    [[self palette] toggleCollapse:self];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [_mouseOverTimer stop];

    NSPoint screenLocation;
    NSRect tabRect;
    [self _getDrawingRectsTabRect:NULL bounds:&tabRect];
    tabRect = [self convertRect:tabRect toView:nil];
    screenLocation = ERCenterPointOfRect([[self window] convertRectToScreen:tabRect]);
    
    [ERPaletteOpenPopup popupWithOrientation:(([[self palette] palettePosition])%2) palettePanel:[self palette] atLocation:screenLocation];
}


- (void)updateTrackingAreas
{
    [self removeTrackingArea:_mouseOverArea];
    [_mouseOverArea release];
    
    
    NSRect bounds;
    [self _getDrawingRectsTabRect:NULL bounds:&bounds];
    _mouseOverArea = [[NSTrackingArea alloc] initWithRect:bounds
                                        options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp )
                                          owner:self userInfo:nil];

    [self addTrackingArea:_mouseOverArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{    
    if ([[self palette] state] == ERPaletteClosed) {
        [_mouseOverTimer start];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [_mouseOverTimer stop];
    
    NSPoint location = [theEvent locationInWindow];
    
    if ([palette state] == ERPaletteTooltip) {
        if (!NSPointInRect(location, [[self palette] contentFilledRect])) { // the mouse is now outside of the palette
            [palette setState:ERPaletteClosed animate:YES];
        }
    }
}

- (void)_timerCallBack
{
    [[self palette] showTooltip:self];
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
