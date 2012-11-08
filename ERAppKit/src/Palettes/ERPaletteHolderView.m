//
//  ERPaletteHolderView.m
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteHolderView.h"

#import <ERAppKit/ERPaletteContentView.h>

static CGFloat __tabMargin = 5.;

@implementation ERPaletteHolderView
+ (CGFloat)tabMargin
{
    return __tabMargin;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _leftPalettes = [[NSMutableArray alloc] init];
        _rightPalettes = [[NSMutableArray alloc] init];
        _upPalettes = [[NSMutableArray alloc] init];
        _downPalettes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)dealloc
{
    [_leftPalettes release];
    [_rightPalettes release];
    [_upPalettes release];
    [_downPalettes release];
    
    [super dealloc];
}

- (void)addPaletteWithContentView:(NSView *)contentView atPosition:(ERPalettePanelPosition)pos
{
    ERPalettePanel *palette = [[ERPalettePanel alloc] initWithContent:contentView position:pos];
    [palette setState:ERPaletteClosed];
    NSMutableArray *tabArray;
    
    switch (pos) {
        case ERPalettePanelPositionRight:
            tabArray = _rightPalettes;
            break;
            
        case ERPalettePanelPositionLeft:
            tabArray = _leftPalettes;
            break;
            
        case ERPalettePanelPositionUp:
            tabArray = _upPalettes;
            break;
            
        case ERPalettePanelPositionDown:
            tabArray = _downPalettes;
            break;
            
        default:
            tabArray = nil;
            break;
    }
    
    [tabArray addObject:palette];
    [palette release];
    
    [[self window] addChildWindow:palette ordered:NSWindowAbove];
    
    switch (pos) {
        case ERPalettePanelPositionRight:
            [self updateRightTabsLocations];
            break;
            
        case ERPalettePanelPositionLeft:
            [self updateLeftTabsLocations];
            break;
            
        case ERPalettePanelPositionUp:
            [self updateUpTabsLocations];
            break;
            
        case ERPalettePanelPositionDown:
            [self updateDownTabsLocations];
            break;
            
        default:
            tabArray = nil;
            break;
    }

}

- (void)updateLeftTabsLocations
{
    CGFloat y = [self frame].size.height - [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _leftPalettes) {
        y -= [palette frame].size.height;
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        
        y -= [ERPaletteHolderView tabMargin];
    }
}

- (void)updateRightTabsLocations
{
    CGFloat y = [self frame].size.height - [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _rightPalettes) {
        NSRect paletteFrame = [palette frame];
        y -= paletteFrame.size.height;
        
        NSPoint frameOrigin = NSMakePoint([self frame].size.width - paletteFrame.size.width, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        
        y -= [ERPaletteHolderView tabMargin];
    }
}

- (void)updateDownTabsLocations
{
    CGFloat x = [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _downPalettes) {
        NSRect paletteFrame = [palette frame];
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        x += paletteFrame.size.width;
        x += [ERPaletteHolderView tabMargin];
    }
}

- (void)updateUpTabsLocations
{
    CGFloat x = [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _upPalettes) {
        NSRect paletteFrame = [palette frame];
        
        NSPoint frameOrigin = NSMakePoint(x, [self frame].size.height - paletteFrame.size.height);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        x += paletteFrame.size.width;
        x += [ERPaletteHolderView tabMargin];
    }
}
@end
