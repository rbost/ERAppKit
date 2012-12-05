//
//  ERPalettePanel.h
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * @enum ERPalettePanelPosition
 * @brief These constants specify the positions of the palettes and their components
 */

typedef enum{
    ERPalettePanelPositionRight = 0,
    ERPalettePanelPositionDown,
    ERPalettePanelPositionLeft,
    ERPalettePanelPositionUp
}ERPalettePanelPosition;

/**
 * @enum ERPaletteState
 * @brief Specifies the state of a palette
 */

typedef enum{
    ERPaletteClosed = 0, /**< The palette is closed */
    ERPaletteOpened, /**< The palette is fully open */
    ERPaletteTooltip /**< The palette only displays a tooltip containing the titlebar */
}ERPaletteState;

/**
 * @enum ERPaletteOpeningDirection
 * @brief Constants that specifies the direction to take to open the palettes
 */

typedef enum {
    ERPaletteInsideOpeningDirection = 10, /**< Inside means opening the palette over the holder view */
    ERPaletteOutsideOpeningDirection /**< Outside means opening the palette on the sides of the holder view */
}ERPaletteOpeningDirection;

@class ERPaletteTabView, ERPaletteHolderView;
@class ERPaletteTitleView, ERPaletteTab;

/**
 * The ERPalettePanel class implements the palette widget and the most important parts of the palettes behavior (palette folding and opening, content management, ...).
 *
 */
@interface ERPalettePanel : NSPanel <NSDraggingSource>
{
    ERPalettePanelPosition _palettePosition;
    ERPaletteState _state;
    ERPaletteOpeningDirection _openingDirection;
    ERPaletteOpeningDirection _preferedOpeningDirection;
    
    NSView *_content;
    ERPaletteTabView *_tabView;
    
    ERPaletteTitleView *_titleView;
    ERPaletteTab *_tabButton;
    
    NSPoint _dragStartingPoint;
}
/** The position of the tab view to which the palette belongs. */ 
@property (assign) ERPalettePanelPosition palettePosition;
/** The palette current state. */
@property (assign) ERPaletteState state;
/** The assigned opening direction. This can be different to the prefered opening direction as this is the actual one. */
@property (assign) ERPaletteOpeningDirection openingDirection;
/** The prefered opening direction. This is not necessarly the actual opening direction as the palette can open in the oposite direction to minimize the number of palette to close when opening. */
@property (assign) ERPaletteOpeningDirection preferedOpeningDirection;
/** The owner tab view. */
@property (assign) ERPaletteTabView *tabView;
/** The tab view holder view. This is only a shortcut for palette.tabView.holder */
@property (readonly) ERPaletteHolderView *holder;
/** The content of the palette. Be aware that that property is retained.*/
@property (retain) NSView *content;
/** The icon of the palette. */
@property (retain) NSImage *icon;
/** The position on the tab view. */
@property (assign) CGFloat locationInTabView;

/**
 * Returns the width of the tab for a palette in ERPalettePanelPositionDown or ERPalettePanelPositionUp
 */
+(CGFloat)tabWidth;
/**
 * Returns the height of the tab for a palette in ERPalettePanelPositionDown or ERPalettePanelPositionUp
 */
+(CGFloat)tabHeight;
/**
 * Returns the size of the tab given the position of the palette
 */
+(NSSize)tabSizeForPanelPosition:(ERPalettePanelPosition)pos;

/**
 * Returns the preferred opening direction for newly created palettes.
 */
+ (ERPaletteOpeningDirection)defaultOpeningDirection;
/**
 * Sets the default opening direction for newly created palettes.
 * @param dir The new default direction.
 */
+ (void)setDefaultOpeningDirection:(ERPaletteOpeningDirection)dir;

/**
 * Initialize a new palette panel
 *
 * @param content The view to be displayed in the palette
 * @param pos The position of the palette
 * @return The newly initialized palette
 */
- (id)initWithContent:(NSView *)content position:(ERPalettePanelPosition)pos;

/**
 * Collapses the palette into its tab
 */
- (IBAction)collapse:(id)sender;
/**
 * Open the palette in the best direction.
 * @remarks This method computes the best direction, i.e. the direction in which the least palettes are closed and opens the palette in that direction
 */
- (IBAction)openInBestDirection:(id)sender;
/**
 * Opens the palette (in the best direction) if it is collapsed or is in a tooltip state and collapse it if is it opened.
 */
- (IBAction)toggleCollapse:(id)sender;
/**
 * Opens the palette as a tooltip
 */
- (IBAction)showTooltip:(id)sender;
/**
 * Opens the palette up if is it possible (i.e. the palette position is either ERPalettePanelPositionDown or ERPalettePanelPositionUp)
 */
- (IBAction)openUp:(id)sender;
/**
 * Opens the palette down if is it possible (i.e. the palette position is either ERPalettePanelPositionDown or ERPalettePanelPositionUp)
 */
- (IBAction)openDown:(id)sender;
/**
 * Opens the palette right if is it possible (i.e. the palette position is either ERPalettePanelPositionRight or ERPalettePanelPositionLeft)
 */
- (IBAction)openRight:(id)sender;
/**
 * Opens the palette left if is it possible (i.e. the palette position is either ERPalettePanelPositionRight or ERPalettePanelPositionLeft)
 */
- (IBAction)openLeft:(id)sender;

/**
 * Returns the content view frame of the palette in the screen coordinates. It will return the frame according to the current opening direction and palette location
 */
- (NSRect)contentScreenFrame;

/**
 * Position the bottom-left corner of the palette tab at a given point in screen coordinates.
 *
 * @param tabOrigin The new position of the window’s bottom-left corner in screen coordinates.
 */
- (void)setTabOrigin:(NSPoint)tabOrigin;

/**
 * Change the state of the palette and possibly animates the change.
 *
 * @param state The new state of the palette
 * @param animate If YES, animates the change, if NO, displays the change immediately
 */
- (void)setState:(ERPaletteState)state animate:(BOOL)animate;

/**
 * Updates the autoresizing masks of the palette components (the tab, the title bar and the content).
 */
- (void)updateAutoresizingMask;
/**
 * Updates the frame and position of the palette components (the tab, the title bar and the content).
 */
- (void)updateContentPlacement;
/**
 * Updates the title bar position and possible animated the change.
 */
- (void)updateTitleViewPlacement:(BOOL)animate;

/**
 * This method compute and returns the position of the palette tab
 * It basically flips the position field according the opening direction
 */
- (ERPalettePanelPosition)effectiveHeaderPosition;

/**
 * Returns the frame of the title bar in the window coordinates
 *
 */
- (NSRect)headerRect;
/**
 * Returns the frame of the tab in the window coordinates
 *
 */
- (NSRect)tabRect;

/**
 * Returns the size of palette's content (excludes the tab but includes the title bar).
 */
- (NSSize)paletteContentSize;
/**
 * Returns the frame of palette's content in window's coordinates (excludes the tab but includes the title bar).
 */
- (NSRect)paletteContentFrame;
/**
 * Returns the frame of palette's content to be actually displayed (excludes the tab but includes the title bar).
 */
- (NSRect)contentFilledRect;
/**
 * Returns the size of the palette when opened.
 */
- (NSSize)openedPaletteSize;
/**
 * Returns the size of the palette when closed.
 */
- (NSSize)closedPaletteSize;
/**
 * Returns the size of the palette when displayed as a tooltip.
 */
- (NSSize)tooltipPaletteSize;
/**
 * Returns the present size of the palette.
 */
- (NSSize)paletteSize;

/**
 * Indicates wether the palettes is attached to a tab view or not
 *
 * @returns Returns YES is the palette is attached (tabView is not nil), NO if it is standalone
 */
- (BOOL)isAttached;

/**
 * Compares the tab location between the receiver and the argument assuming they belong to the same tab view
 */
- (NSComparisonResult)compareLocationInTabView:(ERPalettePanel *)palette;
@end


extern NSString *ERPaletteDidCloseNotification;
extern NSString *ERPaletteDidOpenNotification;

extern NSString *ERPaletteNewFrameKey;

extern NSString *ERPalettePboardType;