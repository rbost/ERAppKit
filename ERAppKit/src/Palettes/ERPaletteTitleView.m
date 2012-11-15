//
//  ERPaletteTitleView.m
//  ERAppKit
//
//  Created by Raphael Bost on 12/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteTitleView.h"

#import "ERPaletteButton.h"
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


- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2) {
        [[self window] toggleCollapse:self];
    }
}
@end
