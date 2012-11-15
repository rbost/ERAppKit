//
//  ERPaletteHolderView.h
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERPalettePanel.h>
#import <ERAppKit/ERPaletteTabView.h>

@interface ERPaletteHolderView : NSView
{
    ERPaletteTabView *_leftTabs;
    ERPaletteTabView *_rightTabs;
    ERPaletteTabView *_upTabs;
    ERPaletteTabView *_downTabs;
}

- (void)addPaletteWithContentView:(NSView *)contentView withTitle:(NSString *)paletteTitle atPosition:(ERPalettePanelPosition)pos;

- (BOOL)isFrameEmptyFromPalettes:(NSRect)frame except:(NSWindow *)window;
@end
