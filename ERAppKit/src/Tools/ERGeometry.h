//
//  ERGeometry.h
//  ERAppKit
//
//  Created by Raphael Bost on 04/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

/**
 \file ERGeometry.h
 \brief Convienience geometry functions
 */

#import <Foundation/Foundation.h>

/**
 Returns the center of the rectangle.
 \param rect The rectangle whose center is computed.
 */

NSPoint ERCenterPointOfRect(NSRect rect);

NSRect ERSetCenterPointOfRect(NSRect rect, NSPoint newCenter);

/**
 Translate rect so it is contained in container.
 \param rect The rect we want to translate.
 \param container The container rectangle.
 \remark If rect cannot fit, it is put such that rect.orgin == container.origin
 */
NSRect ERPutRectInRect(NSRect rect,NSRect container);


/**
 Translate rect so it is contained in container with a margin.
 \param rect The rect we want to translate.
 \param container The container rectangle.
 \param xMargin The margin on the x axis
 \param yMargin The margin on the y axis
 \remark If rect cannot fit, it is put such that rect.orgin == container.origin
 */
NSRect ERPutRectInRectWithMargin(NSRect rect,NSRect container, CGFloat xMargin, CGFloat yMargin);


#define UPPER_LEFT_CORNER(rect) NSMakePoint(NSMinX(rect),NSMaxY(rect))
#define LOWER_LEFT_CORNER(rect) NSMakePoint(NSMinX(rect), NSMinY(rect))
#define UPPER_RIGHT_CORNER(rect) NSMakePoint(NSMaxX(rect), NSMaxY(rect))
#define LOWER_RIGHT_CORNER(rect) NSMakePoint(NSMaxX(rect), NSMinY(rect))

#define SQUARED_NORM(p) p.x*p.x+p.y*p.y