//
//  NSBezierPath+ERAppKit.h
//  ERAppKit
//
//  Created by Raphael Bost on 17/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * @enum ERCorner
 * @brief These constants specify corners of a rectangle.
 */
typedef enum{
    ERNoneCorner = 0, /**< No corner */
    ERUpperLeftCorner = 1,
    ERLowerLeftCorner = 1 << 1,
    ERUpperRightCorner = 1 << 2,
    ERLowerRightCorner = 1 << 3,
    ERAllCorners = ~0 /**< All four corners */
}ERCorner;

/**
 * The ERAppKit NSBezierPath category provides a few convenience methods used to draw ERAppKit's widgets.
 */
@interface NSBezierPath (ERAppKit)
/**
 * Creates and returns a new NSBezierPath object initalized with a rectangular path rounded at some corners.
 *
 * @param rect The rectangle that defines the basic shape of the path.
 * @param radius The radius of each rounded corner.
 * @param cornerMasks The corners to be rounded.
 * @return A new path object with the rounded rectangular path.
 */
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect radius:(CGFloat)radius corners:(int)cornerMasks;
/**
 * Appends to the receiver a rectangular path rounded at some corners.
 *
 * @param rect The rectangle that defines the basic shape of the path.
 * @param radius The radius of each rounded corner.
 * @param cornerMasks The corners to be rounded.
 * @return A new path object with the rounded rectangular path.
 */
- (void)appendBezierPathWithRoundedRect:(NSRect)rect radius:(CGFloat)radius corners:(int)cornerMasks;

/**
 * Creates and returns a new NSBezierPath object initialized with an arrow center on the NSZeroPoint.
 */
+ (NSBezierPath *)centeredRightArrow;
@end
