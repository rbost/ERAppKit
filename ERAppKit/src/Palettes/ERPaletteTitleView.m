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
    if (_draggingStartPoint.x != NSNotFound) {
        NSPoint screenLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSPoint delta = _draggingStartPoint;
        delta.x -= screenLocation.x ;
        delta.y -= screenLocation.y ;
        
        if (sqrt(delta.x*delta.x + delta.y*delta.y) > 10) {
            
            NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSDragPboard];
            [pBoard declareTypes:[NSArray arrayWithObject:ERPalettePboardType] owner:[self window]];
            [pBoard setString:NSStringFromSize([self frame].size) forType:ERPalettePboardType];
            
            NSPoint imageLocation = screenLocation;
            NSSize imageSize = [self bounds].size;
            
            imageLocation.x -= _draggingStartPoint.x;
            imageLocation.y -= _draggingStartPoint.y;
            
            [self dragImage:[self draggingImage] at:imageLocation offset:NSZeroSize event:theEvent pasteboard:pBoard source:[self window] slideBack:YES];
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2) {
        [[self window] toggleCollapse:self];
    }
    _draggingStartPoint = NSMakePoint(NSNotFound, NSNotFound);
    
}


@end
