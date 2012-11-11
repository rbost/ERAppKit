//
//  ERPaletteTabButton.m
//  ERAppKit
//
//  Created by Raphael Bost on 11/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteTabButton.h"

@implementation ERPaletteTabButton

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
    [[NSColor purpleColor] set];
    [[NSBezierPath bezierPathWithOvalInRect:[self bounds]] fill];
}

@end
