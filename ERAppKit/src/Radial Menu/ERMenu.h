//
//  ERMenu.h
//  ERAppKit
//
//  Created by Raphael Bost on 02/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ERAppKit/ERGlobals.h>

/**
 Wrapper class to display radial menus.
 NSMenu objects are used as datas for the radial menus: they contain the menu items titles, actions, submenus, ...
 
 Different styles can be set for radial menus.
 */
@interface ERMenu : NSObject
/**
 Displays radial contextual menu over a view for an event in a specified direction.
 \param menu The menu object to use for the contextual menu.
 \param event An NSEvent object representing the event.
 \param view The view object over which to display the contextual menu.
 \param style The style for the radial menu.
 \param direction The direction in angle of the menu.
 */

+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view menuStyle:(ERMenuStyle)style direction:(CGFloat)direction;

/**
 Displays radial contextual menu over a view for an event in the default direction (90 degrees).
 \param menu The menu object to use for the contextual menu.
 \param event An NSEvent object representing the event.
 \param view The view object over which to display the contextual menu.
 \param style The style for the radial menu.
 */
+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view menuStyle:(ERMenuStyle)style;

/**
 Displays radial contextual menu over a view for an event with the default style.
 \param menu The menu object to use for the contextual menu.
 \param event An NSEvent object representing the event.
 \param view The view object over which to display the contextual menu.
 */
+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view;


/**
 Displays radial contextual menu over a view at a location and in a specified direction.
 \param menu The menu object to use for the contextual menu.
 \param point A point representing the center position of the contextual menu.
 \param view The view object over which to display the contextual menu.
 \param style The style for the radial menu.
 \param direction The direction in angle of the menu.
 */
+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view menuStyle:(ERMenuStyle)style direction:(CGFloat)direction;

/**
 Displays radial contextual menu over a view at a location in the default direction (90 degrees).
 \param menu The menu object to use for the contextual menu.
 \param point A point representing the center position of the contextual menu.
 \param view The view object over which to display the contextual menu.
 \param style The style for the radial menu
 */
+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view menuStyle:(ERMenuStyle)style;

/**
 Displays radial contextual menu over a view at a location with the default style.
 \param menu The menu object to use for the contextual menu.
 \param point A point representing the center position of the contextual menu.
 \param view The view object over which to display the contextual menu.
 */
+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view;




/**
 Returns the gradient to fill a selected menu item
 \remarks If this method returns nil, then you should use selectedItemColor.
 \remarks Returns by default \verbatim [[NSGradient alloc] initWithStartingColor:
 [NSColor colorWithCalibratedRed:.396 green:.541 blue:.941 alpha:1.]
 endingColor:
 [NSColor colorWithCalibratedRed:.157 green:.384 blue:.929 alpha:1.]] \endverbatim
 */
+ (NSGradient *)selectedItemGradient;
/**
 Sets the gradient used to fill a selected menu item.
 \param gradient The new gradient used to fill selected items.
 \remarks If gradient is not nil, this method set selectedItemColor to nil.
 */
+ (void)setSelectedItemGradient:(NSGradient *)gradient;

/**
 Returns the color used to fill a selected menu item.
 \remarks If this method returns nil, then you should use selectedItemGradient.
 \remarks Return nil by default
 */
+ (NSColor *)selectedItemColor;
/**
 Sets the color used to fill a selected menu item.
 \param color The new color used to fill selected items.
 \remarks If color is not nil, this method set selectedItemGradient to nil.
 */
+ (void)setSelectedItemColor:(NSColor *)color;
/**
 Returns the color used to stroke a selected menu item boundaries.
 \remarks Return by default \verbatim [NSColor colorWithCalibratedRed:0.898 green:0.898 blue:0.898 alpha:1] \endverbatim 
 */

+ (NSColor *)selectedItemStrokeColor;
/**
 Sets the color used to stroke a selected menu item boundaries.
 */
+ (void)setSelectedItemStrokeColor:(NSColor *)color;


/**
 Returns the color used to stroke the submenu arrow of a submenu item.
 \remarks Return [NSColor colorWithCalibratedWhite:0.3 alpha:1.] by default
 */
+ (NSColor *)submenuArrowColor;
/**
 Sets the color used to stroke the submenu arrow of a submenu item.
 \param color The new color
 */
+ (void)setSubmenuArrowColor:(NSColor *)color;

/**
 Returns the color used to stroke the submenu arrow of a submenu item when selected.
 \remarks Return [NSColor whiteColor] by default
 */
+ (NSColor *)submenuArrowSelectedColor;
/**
 Sets the color used to stroke the submenu arrow of a submenu item when selected.
 \param color The new color
 */
+ (void)setSubmenuArrowSelectedColor:(NSColor *)color;

/**
 Returns the gradient to fill a menu item
 \remarks If this method returns nil, then you should use itemColor.
 \remarks Return nil by default
 */
+ (NSGradient *)itemGradient;
/**
 Set the gradient to fill a menu item.
 \param gradient The new gradient used to fill items.
 \remarks If gradient is not nil, this method set itemColor to nil.
 */
+ (void)setItemGradient:(NSGradient *)gradient;

/**
 Returns the color to fill a menu item.
 \remarks If this method returns nil, then you should use itemGradient.
 \remarks Returns \verbatim [NSColor controlBackgroundColor] \endverbatim by default 
 */
+ (NSColor *)itemColor;
/**
 Set the color to fill a menu item.
 \param color The new color used to fill items.
 \remarks If color is not nil, this method set itemGradient to nil.
 */
+ (void)setItemColor:(NSColor *)color;

/**
 Returns the color used to stroke a menu item boundaries.
 \remarks Return by default \verbatim [NSColor colorWithCalibratedRed:0.898 green:0.898 blue:0.898 alpha:1] \endverbatim
 */
+ (NSColor *)itemStrokeColor;
/**
 Sets the color used to stroke a menu item boundaries.
 */
+ (void)setItemStrokeColor:(NSColor *)color;




/**
 Returns the attributes used to display the title of a menu item
 \remarks By default, these are \verbatim  [[NSDictionary alloc] initWithObjectsAndKeys:
 [NSColor textColor], NSForegroundColorAttributeName,
 [NSFont controlContentFontOfSize:11.0], NSFontAttributeName,
 nil] \endverbatim
 */
+ (NSDictionary *)menuItemTitleAttributes;
/**
 Sets the attributes used to display the title of a menu item
 \param dict The attribute dictionary. See NSAttributedString documentation
 */
+ (void)setMenuItemTitleAttributes:(NSDictionary *)dict;

/**
 Returns the attributes used to display the title of a menu item
 \remarks By default, these are \verbatim  [[NSDictionary alloc] initWithObjectsAndKeys:
 [NSColor selectedMenuItemTextColor], NSForegroundColorAttributeName,
 [NSFont controlContentFontOfSize:11.0], NSFontAttributeName,
 nil] \endverbatim
 */
+ (NSDictionary *)selectedMenuItemTitleAttributes;
/**
 Sets the attributes used to display the title of a selected menu item
 \param dict The attribute dictionary. See NSAttributedString documentation
 */
+ (void)setSelectedMenuItemTitleAttributes:(NSDictionary *)dict;



/**
 Returns YES if the central menu item (the one closing the menu) is filled when not selected and NO otherwise.
 \remarks Returns YES by default.
 */
+ (BOOL)fillCentralMenuItem;
/**
 Sets if the central menu item has to be filled or not.
 \param flag YES is it has to be filled, NO otherwise.
 */
+ (void)setFillCentralMenuItem:(BOOL)flag;

/**
 Returns whether submenus should be opened when the mouse is over a menu item.
 */
+ (BOOL)openSubmenusOnMouseOver;
/**
 Sets whether submenus should be opened when the mouse is over a menu item.
 */
+ (void)setOpenSubmenusOnMouseOver:(BOOL)flag;

/**
 Returns the time interval necessary to open a submenu when mouse is over.
 */
+ (NSTimeInterval)mouseOverMenuOpeningInterval;
/**
 Sets the time interval necessary to open a submenu when mouse is over.
 \remarks This methods  does nothing when openSubmenusOnMouseOver is set to NO
 */
+ (void)setMouseOverMenuOpeningInterval:(NSTimeInterval)interval;

/**
 Returns the radius of the central button of radial menus.
 */
+ (CGFloat)centralButtonRadius;
/**
 Sets the radius of the central button of radial menus.
 \param r The new radius.
 \remarks Sets the new radius to min(r,menuRadius-10).
*/
+ (void)setCentralButtonRadius:(CGFloat)r;

/**
 Returns the radius of radial menus.
 */
+ (CGFloat)menuRadius;
/**
 Sets the radius of radial menus.
 \param r The new radius.
 \remarks Sets the new radius to max(r,centralButtonRadius+10).   
 */
+ (void)setMenuRadius:(CGFloat)r;
@end
