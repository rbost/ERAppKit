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
    NSMutableArray *_tabViews;
}

/**
 * Adds a new tab to the receiver. 
 * @param view The added tab view. It should be entirely intialized (position, frame, ...) before added to ensure correct functionning
 */
- (void)addTabView:(ERPaletteTabView *)view;

/**
 * Initializes a new tab view and adds it the the receiver's tab views.
 * @param tabSize The size of the newly initialized tab view. For vertical tabs (if position is left and right, this sets the height of the tab view; otherwise sets the width).
 * @param location The location of the newly initialized tab view (if position is left and right, this sets the y position of the tab view; otherwise sets the x position).
 * @param pos The position of the newly initialized tab view. See ERPaletteTabView class documentation.
 * @return The newly intialized tab view.
 */
- (ERPaletteTabView *)addTabViewWithSize:(CGFloat)tabSize location:(CGFloat)location position:(ERPalettePanelPosition)pos;

/**
 * Initializes a new tab view with the maximum size and adds it the the receiver's tab views.
 * @param pos The position of the newly initialized tab view. See ERPaletteTabView class documentation.
 * @return The newly intialized tab view.
 */
- (ERPaletteTabView *)addTabViewWithPosition:(ERPalettePanelPosition)pos;


/**
 * Removes a tab view to the receiver.
 * @param view The tab view to remove.
 */
- (void)removeTabView:(ERPaletteTabView *)view;

/**
 * Checks if a screen frame contains some palette
 *
 * @param frame The frame to check, in the screen coordinates
 * @param window The exception window: the method returns YES even if window is the only window to intersect the parameter frame
 * @return YES if no palette (except window) of the holder view intersects frame  
 */
- (BOOL)isFrameEmptyFromPalettes:(NSRect)frame except:(NSWindow *)window;

@end

@interface NSScreen (ERAppKit)
/**
 * Returns YES if the frame is entirely visible on screen.
 *
 * @param frame The frame to check.
 */
+ (BOOL)isFrameOnscreen:(NSRect)frame;
@end

