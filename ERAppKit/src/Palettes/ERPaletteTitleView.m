//
//  ERPaletteTitleView.m
//  ERAppKit
//
//  Created by Raphael Bost on 12/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteTitleView.h"

@implementation ERPaletteTitleView

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
    [[NSColor colorWithCalibratedWhite:0.5 alpha:0.5] set];

    [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:[self bounds].size.height/2. yRadius:[self bounds].size.height/2.] fill];
    
    [@"Header" drawAtPoint:NSMakePoint(10, 0) withAttributes:nil];
}

@end
