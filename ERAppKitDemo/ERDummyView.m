//
//  ERDummyView.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERDummyView.h"

#import <ERAppKit/ERMenu.h>

@implementation ERDummyView

@synthesize delegate, color;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setColor:[NSColor whiteColor]];
    }
    
    return self;
}

- (void)dealloc
{
    [self setColor:nil];
    
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    [[self color] set];
    [NSBezierPath fillRect:dirtyRect];
}

- (void)mouseDown:(NSEvent *)theEvent
{
//    [delegate showDummyMenu:theEvent];
    [ERMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self menuStyle:EREmptyQuarterMenuStyle direction:135];
}

- (IBAction)setWhite:(id)sender
{
    [self setColor:[NSColor whiteColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setRed:(id)sender
{
    [self setColor:[NSColor redColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setGreen:(id)sender
{
    [self setColor:[NSColor greenColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setYellow:(id)sender
{
    [self setColor:[NSColor yellowColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setBlue:(id)sender
{
    [self setColor:[NSColor blueColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setOrange:(id)sender
{
    [self setColor:[NSColor orangeColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setPurple:(id)sender
{
    [self setColor:[NSColor purpleColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setGray:(id)sender
{
    [self setColor:[NSColor grayColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setBlack:(id)sender
{
    [self setColor:[NSColor blackColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setMagenta:(id)sender
{
    [self setColor:[NSColor magentaColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setCyan:(id)sender
{
    [self setColor:[NSColor cyanColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setDarkGray:(id)sender
{
    [self setColor:[NSColor darkGrayColor]];
    [self setNeedsDisplay:YES];
}
- (IBAction)setClear:(id)sender
{
    [self setColor:[NSColor clearColor]];
    [self setNeedsDisplay:YES];
}


@end
