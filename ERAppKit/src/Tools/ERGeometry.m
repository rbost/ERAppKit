//
//  ERGeometry.m
//  ERAppKit
//
//  Created by Raphael Bost on 04/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERGeometry.h"

NSPoint ERCenterPointOfRect(NSRect rect)
{
    NSPoint center = rect.origin;
    
    center.x += .5*rect.size.width;
    center.y += .5*rect.size.height;
    
    return center;
}

NSRect ERSetCenterPointOfRect(NSRect rect, NSPoint newCenter)
{
    NSPoint center = ERCenterPointOfRect(rect);
    
    CGFloat dX, dY;
    dX = newCenter.x - center.x;
    dY = newCenter.y - center.y;

    NSRect newRect = rect;
    
    newRect.origin.x += dX;
    newRect.origin.y += dY;
    
    return newRect;
}

NSRect ERPutRectInRect(NSRect rect,NSRect container)
{
    if(NSContainsRect(container, rect)){ // if rect is in the container, just return rect
    }else{
        CGFloat dX, dY;
        
        dX = NSMaxX(rect) - NSMaxX(container);
        if(dX > 0.){ // the right limit of rect is off-container
            rect.origin.x -= dX;
        }
        
        dX = NSMinX(rect) - NSMinX(container);
        if(dX < 0.){ // the left limit of rect is off-container
            rect.origin.x -= dX;
        }
        
        dY = NSMaxY(rect) - NSMaxY(container);
        if(dY > 0.){ // the upper limit of rect is off-container
            rect.origin.y -= dY;
        }
        
        dY = NSMinY(rect) - NSMinY(container);
        if(dY < 0.){ // the lower limit of rect is off-container
            rect.origin.y -= dY;
        }
        
    }
    return rect;
}

NSRect ERPutRectInRectWithMargin(NSRect rect,NSRect container, CGFloat xMargin, CGFloat yMargin)
{
    return ERPutRectInRect(rect, NSInsetRect(container, xMargin, yMargin));
}
