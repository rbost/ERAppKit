//
//  ERPaletteContentView.m
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteContentView.h"

#import <ERAppKit/ERPalettePanel.h>
#import <ERAppKit/ERPaletteTabView.h>
#import <ERAppKit/NSBezierPath+ERAppKit.h>

static CGFloat __paletteTitleHeight = 20.;

@implementation ERPaletteContentView

+ (CGFloat)paletteTitleHeight
{
    return __paletteTitleHeight;
}

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

    NSRect filledRect;
    filledRect = [(ERPalettePanel *)[self window] contentFilledRect];

    int corners;
    
    switch ([(ERPalettePanel *)[self window] effectiveHeaderPosition]) {
        case ERPalettePanelPositionUp:
            corners = ERUpperRightCorner | ERUpperLeftCorner | ERLowerRightCorner;
            break;
            
        case ERPalettePanelPositionDown:
            corners = ERUpperRightCorner  | ERLowerRightCorner | ERLowerLeftCorner;
            break;
            
        case ERPalettePanelPositionLeft:
            corners = ERLowerLeftCorner | ERUpperLeftCorner | ERLowerRightCorner;
            break;
            
        case ERPalettePanelPositionRight:
            corners = ERUpperRightCorner | ERLowerRightCorner | ERLowerLeftCorner;
            break;
            
        default:
            corners = ERAllCorners;
            break;
    }
    NSBezierPath *bckGrd = [NSBezierPath bezierPathWithRoundedRect:filledRect radius:5. corners:ERAllCorners];
    bckGrd = [NSBezierPath bezierPathWithRoundedRect:filledRect xRadius:5. yRadius:5.];
    [[NSColor colorWithCalibratedWhite:0.1 alpha:0.95] set];
    [bckGrd fill];
    [[NSColor colorWithCalibratedWhite:0.5 alpha:0.95] set];
//    [bckGrd stroke];
}

- (NSRect)headerRect
{
    NSRect headerRect = NSZeroRect;
    ERPalettePanel *window = (ERPalettePanel *)[self window];
    NSView *content = [window content];

    switch ([window effectiveHeaderPosition]) {
        case ERPalettePanelPositionDown:
            headerRect.origin = NSMakePoint(0, [content frame].size.height);
            break;
            
        case ERPalettePanelPositionLeft:
            headerRect.origin = NSMakePoint(0, [content frame].size.height);
            break;
        case ERPalettePanelPositionUp:
            headerRect.origin = NSMakePoint(0,[ERPalettePanel tabHeight]);
            break;
        case ERPalettePanelPositionRight:
            headerRect.origin = NSMakePoint([ERPalettePanel tabHeight], [content frame].size.height);

            break;
        default:
            break;
    }
    headerRect.size = NSMakeSize([[window content] bounds].size.width, [ERPaletteContentView paletteTitleHeight]);
    
    return headerRect;
}

- (NSRect)contentRect
{
    return [[(ERPalettePanel *)[self window] content] frame];
}
@end
