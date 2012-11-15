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

static CGFloat __paletteTitleSize = 20.;

@implementation ERPaletteContentView

+ (CGFloat)paletteTitleSize
{
    return __paletteTitleSize;
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
    
    NSRect filledRect = NSIntersectionRect([self frame],[self contentRect]);

    NSBezierPath *bckGrd = [NSBezierPath bezierPathWithRoundedRect:filledRect xRadius:5. yRadius:5.];
    [[NSColor colorWithCalibratedWhite:0.2 alpha:0.9] set];
    [bckGrd fill];
    [[NSColor colorWithCalibratedWhite:0.5 alpha:0.9] set];
    [bckGrd stroke];
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
            headerRect.origin = NSMakePoint(0,__paletteTitleSize);
            break;
        case ERPalettePanelPositionRight:
            headerRect.origin = NSMakePoint(__paletteTitleSize, [content frame].size.height);

            break;
        default:
            break;
    }
    headerRect.size = NSMakeSize([[window content] bounds].size.width, [ERPaletteContentView paletteTitleSize]);
    
    return headerRect;
}

- (NSRect)tabRect
{
    NSRect tabRect = NSZeroRect;
    ERPalettePanel *window = (ERPalettePanel *)[self window];
    
    switch ([window effectiveHeaderPosition]) {
        case ERPalettePanelPositionDown:
            tabRect.origin = NSMakePoint( 0, [window frame].size.height- __paletteTitleSize);
            break;
            
        case ERPalettePanelPositionLeft:
            tabRect.origin = NSMakePoint( [window frame].size.width- __paletteTitleSize ,[window frame].size.height -__paletteTitleSize);
            break;
        case ERPalettePanelPositionUp:
            tabRect.origin = NSZeroPoint;
            break;
        case ERPalettePanelPositionRight:
            tabRect.origin = NSMakePoint( 0,[window frame].size.height -__paletteTitleSize);
            break;
        default:
            break;
    }
    
    tabRect.size = NSMakeSize([ERPaletteContentView paletteTitleSize], [ERPaletteContentView paletteTitleSize]);
    return tabRect;

}

- (NSRect)contentRect
{
    return [[(ERPalettePanel *)[self window] content] frame];
}
@end
