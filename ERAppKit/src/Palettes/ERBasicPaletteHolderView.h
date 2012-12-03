//
//  ERBasicPaletteHolderView.h
//  ERAppKit
//
//  Created by Raphael Bost on 02/12/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <ERAppKit/ERPaletteHolderView.h>

@interface ERBasicPaletteHolderView : ERPaletteHolderView
{
    ERPaletteTabView *_leftTabs;
    ERPaletteTabView *_rightTabs;
    ERPaletteTabView *_upTabs;
    ERPaletteTabView *_downTabs;
}

/**
 * Adds a palette with the specified content view, icon and title on the given tab bar
 *
 * @param contentView The content of the new palette
 * @param icon The icon associated with the new palette
 * @param paletteTitle The title chosen for the palette
 * @param pos The position representing the tab bar used to add put the new palette
 */
- (void)addPaletteWithContentView:(NSView *)contentView icon:(NSImage *)icon title:(NSString *)paletteTitle atPosition:(ERPalettePanelPosition)pos;

@end
