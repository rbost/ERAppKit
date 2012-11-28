//
//  ERPaletteButton.m
//  ERAppKit
//
//  Created by Raphael Bost on 15/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteButton.h"

@implementation ERPaletteButton

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
    NSRect bounds = [self bounds];
    NSRect crossRect = NSInsetRect(bounds, 2., 2.);
    
    NSBezierPath *cross = [NSBezierPath bezierPath];
    [cross moveToPoint:NSMakePoint(NSMinX(crossRect), NSMinY(crossRect))];
    [cross lineToPoint:NSMakePoint(NSMaxX(crossRect), NSMaxY(crossRect))];
    [cross moveToPoint:NSMakePoint(NSMaxX(crossRect), NSMinY(crossRect))];
    [cross lineToPoint:NSMakePoint(NSMinX(crossRect), NSMaxY(crossRect))];
    
    
    [[NSColor colorWithCalibratedWhite:0.2 alpha:1.0] set];
    [[NSBezierPath bezierPathWithOvalInRect:bounds] fill];
    
    [[NSColor whiteColor] set];
    [cross stroke];
    
}

@end
