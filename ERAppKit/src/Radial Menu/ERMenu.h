//
//  ERMenu.h
//  ERAppKit
//
//  Created by Raphael Bost on 02/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ERAppKit/ERGlobals.h>

@interface ERMenu : NSObject

/**
 Displays radial contextual menu over a view for an event.
 @param menu The menu object to use for the contextual menu.
 @param event An NSEvent object representing the event.
 @param view The view object over which to display the contextual menu.
 @param style The style for the radial menu
 */
+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view menuStyle:(ERMenuStyle)style;

/**
 Displays radial contextual menu over a view for an event with the default style.
 @param menu The menu object to use for the contextual menu.
 @param event An NSEvent object representing the event.
 @param view The view object over which to display the contextual menu.
 */
+ (void)popUpContextMenu:(NSMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view;


/**
 Displays radial contextual menu over a view at a location.
 @param menu The menu object to use for the contextual menu.
 @param point A point representing the center position of the contextual menu.
 @param view The view object over which to display the contextual menu.
 @param style The style for the radial menu
 */

+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view menuStyle:(ERMenuStyle)style;

/**
 Displays radial contextual menu over a view at a location with the default style.
 @param menu The menu object to use for the contextual menu.
 @param point A point representing the center position of the contextual menu.
 @param view The view object over which to display the contextual menu.
 */
+ (void)popUpContextMenu:(NSMenu *)menu atLocation:(NSPoint)point inView:(NSView *)view;
@end
