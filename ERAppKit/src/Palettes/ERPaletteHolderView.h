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

/**
 * ERPaletteHolderView is the wrapper class for the palette widgets: you basically only need to use this to implement palettes.
 * You just have to creat a holder view which will be the superview of your content (like a NSScrollView) and it will creates the necessary tab views all around the holder view.
 * Then, you will be able to add palettes by specifying their content view, title and icon.
 */

@interface ERPaletteHolderView : NSView
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

/**
 * Checks if a screen frame contains some palette
 *
 * @param frame The frame to check, in the screen coordinates
 * @param window The exception window: the method returns YES even if window is the only window to intersect the parameter frame
 * @return YES if no palette (except window) of the holder view intersects frame  
 */
- (BOOL)isFrameEmptyFromPalettes:(NSRect)frame except:(NSWindow *)window;
@end
