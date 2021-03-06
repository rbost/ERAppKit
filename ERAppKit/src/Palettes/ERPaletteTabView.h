//
//  ERPaletteTabView.h
//  ERAppKit
//
//  Created by Raphael Bost on 08/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERPalettePanel.h>

@class ERPaletteHolderView;

/**
 * The ERPaletteTabView class organizes the palettes tabs and implements tabs drag and drops
 */
@interface ERPaletteTabView : NSView
{
    BOOL _highlight;
    
    @protected
    NSMutableArray *_tabs;
    ERPaletteHolderView *_holder;
    ERPalettePanelPosition _position;
    
    
    NSRect _draggingPositionMarker;
    
    NSRect _barFrame;
}
/** Palettes attached to the tab view */
@property (readonly) NSArray *tabs;
/** The position of the tab view with respect to the holder view */
@property (readonly) ERPalettePanelPosition position;
/** The holder view owning the tab view. Should also view the receiver's superview.*/
@property (readonly) ERPaletteHolderView *holder;
/** The rectangle frame of the displayed bar */
@property (assign) NSRect barFrame;
/**
 * Returns the margin between the palette tabs.
 */
+ (CGFloat)tabMargin;

/**
 * Returns the thickness of the tab bars.
 */
+ (CGFloat)barThickness;

/**
 * Intializes a newly created tab view.
 *
 * @param holder The holder view owning the new tab view.
 * @param position The position of the tab view with respect to the holder
 * @return The newly initialized tab view
 */
- (id)initWithHolder:(ERPaletteHolderView *)holder position:(ERPalettePanelPosition)position;

/**
 * Intializes a newly created tab view and specifies its frame.
 *
 * @param holder The holder view owning the new tab view.
 * @param frame The frame of the newly initialized tab view.
 * @param position The position of the tab view with respect to the holder
 * @return The newly initialized tab view
 */
- (id)initWithHolder:(ERPaletteHolderView *)holder frame:(NSRect)frame position:(ERPalettePanelPosition)position;

/**
 * Add a newly initialized palette with a given content view, icon and title
 *
 * @param contentView The content view of the new palette.
 * @param icon The tab icon of the palette.
 * @param paletteTitle The title of the new palette.
 */
- (void)addPaletteWithContentView:(NSView *)contentView icon:(NSImage *)icon title:(NSString *)paletteTitle;
/**
 * Add a palette to the receiver.
 * @param palette The palette to add.
 */
- (void)addPalette:(ERPalettePanel *)palette;
/**
 * Add a palette and insert it in the receiver at the specified location.
 * @param palette The palette to be inserted.
 * @param loc The desired location for the newly inserted palette.
 */
- (void)insertPalette:(ERPalettePanel *)palette atLocation:(CGFloat)loc;
/**
 * Removes a palette from the receiver.
 *
 * @param palette The palette to be removed.
 */
- (void)removePalette:(ERPalettePanel *)palette;

/**
 * Recomputes the position of the tabs according to their desired location.
 */
- (void)updateTabsLocations;

/**
 * Display the bar as collapsed if there is no tab, open it otherwise.
 * @param animate YES if you want to show an animation when updating the bar frame. NO otherwise.
 */
- (void)updateBarFrame:(BOOL)animate;
@end


@interface ERPaletteTabView (PalettesDragAndDrop)
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;
- (void)draggingExited:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;
@end