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
