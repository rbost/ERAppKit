//
//  ERPaletteOpenButton.m
//  ERAppKit
//
//  Created by Raphael Bost on 24/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteOpenButton.h"

#import <ERAppKit/NSBezierPath+ERAppKit.h>

@implementation ERPaletteOpenButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSColor colorWithCalibratedWhite:0.1 alpha:0.95] set];
    [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:5. yRadius:5.] fill];
   
    NSRect bounds = [self bounds];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSAffineTransform *at = [NSAffineTransform transform];
    [at translateXBy:bounds.size.width/2. yBy:bounds.size.height/2.];
    [at scaleBy:0.9];
    [at rotateByDegrees:-orientation*90.];
    
    [at concat];
    
    [[NSColor whiteColor] set];
    [[NSBezierPath centeredRightArrow] fill];
    
    
    [NSGraphicsContext restoreGraphicsState];
}

@synthesize orientation;

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    [[self window] close];
}
@end
