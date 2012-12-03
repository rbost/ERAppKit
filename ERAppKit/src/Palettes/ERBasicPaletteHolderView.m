//
//  ERBasicPaletteHolderView.m
//  ERAppKit
//
//  Created by Raphael Bost on 02/12/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERBasicPaletteHolderView.h"

@implementation ERBasicPaletteHolderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        _leftTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionLeft];
        _rightTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionRight];
        _upTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionUp];
        _downTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionDown];
        
        [self setAutoresizesSubviews:YES];
        
        [self addTabView:_leftTabs]; [_leftTabs release]; [_leftTabs setAutoresizingMask:(NSViewHeightSizable|NSViewMaxXMargin)];
        [self addTabView:_rightTabs]; [_rightTabs release]; [_rightTabs setAutoresizingMask:(NSViewHeightSizable|NSViewMinXMargin)];
        [self addTabView:_upTabs]; [_upTabs release]; [_upTabs setAutoresizingMask:(NSViewWidthSizable|NSViewMinYMargin)];
        [self addTabView:_downTabs]; [_downTabs release]; [_downTabs setAutoresizingMask:(NSViewWidthSizable|NSViewMaxYMargin)];
    }
    
    return self;
}

- (void)addPaletteWithContentView:(NSView *)contentView icon:(NSImage *)icon title:(NSString *)paletteTitle atPosition:(ERPalettePanelPosition)pos
{
    switch (pos) {
        case ERPalettePanelPositionRight:
            [_rightTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        case ERPalettePanelPositionLeft:
            [_leftTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        case ERPalettePanelPositionUp:
            [_upTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        case ERPalettePanelPositionDown:
            [_downTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        default:
            break;
    }
}

@end
