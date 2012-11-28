//
//  ERPalettePopupContentView.m
//  ERAppKit
//
//  Created by Raphael Bost on 24/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteOpenPopupContentView.h"

@implementation ERPaletteOpenPopupContentView

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
//    [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:5. yRadius:5.] fill];
}

@end
