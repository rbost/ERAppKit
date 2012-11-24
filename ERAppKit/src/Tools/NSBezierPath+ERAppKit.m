//
//  NSBezierPath+ERAppKit.m
//  ERAppKit
//
//  Created by Raphael Bost on 17/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "NSBezierPath+ERAppKit.h"

@implementation NSBezierPath (ERAppKit)
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect radius:(CGFloat)radius corners:(int)cornerMasks
{
    NSBezierPath *bp = [NSBezierPath bezierPath];
    
    [bp appendBezierPathWithRoundedRect:rect radius:radius corners:cornerMasks];
    
    return bp;
}

- (void)appendBezierPathWithRoundedRect:(NSRect)aRect radius:(CGFloat)radius corners:(int)cornerMasks
{
    NSPoint ul, ur, ll, lr;
    ll = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
    lr = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
    ul = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
    ur = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
    
    [self moveToPoint:NSMakePoint(ll.x, ll.y+radius)];
    
    if (cornerMasks & ERUpperLeftCorner) { // rounded upper left corner
        [self lineToPoint:NSMakePoint(ul.x, ul.y-radius)];
        [self appendBezierPathWithArcWithCenter:NSMakePoint(ul.x+radius, ul.y-radius) radius:radius startAngle:180 endAngle:90 clockwise:YES];
    }else{
        [self lineToPoint:ul];
    }

    if (cornerMasks & ERUpperRightCorner) { // rounded upper right corner        
        [self lineToPoint:NSMakePoint(ur.x-radius, ur.y)];
        [self appendBezierPathWithArcWithCenter:NSMakePoint(ur.x-radius, ur.y-radius) radius:radius startAngle:90 endAngle:0 clockwise:YES];
    }else{
        [self lineToPoint:ur];
    }

    if (cornerMasks & ERLowerRightCorner) { // rounded lower right corner
        [self lineToPoint:NSMakePoint(lr.x, lr.y+radius)];
        [self appendBezierPathWithArcWithCenter:NSMakePoint(lr.x-radius, lr.y+radius) radius:radius startAngle:0 endAngle:-90 clockwise:YES];
    }else{
        [self lineToPoint:lr];
    }

    if (cornerMasks & ERLowerLeftCorner) { // rounded lower left corner
        [self lineToPoint:NSMakePoint(ll.x+radius, ll.y)];
        [self appendBezierPathWithArcWithCenter:NSMakePoint(ll.x+radius, ll.y+radius) radius:radius startAngle:-90 endAngle:-180 clockwise:YES];
    }else{
        [self lineToPoint:ll];
    }

    [self closePath];
}


+ (NSBezierPath *)centeredRightArrow
{
    NSBezierPath *arrow = [NSBezierPath bezierPath];
    
    CGFloat y1 = 7.,y2 = 12.;
    CGFloat x1 = 12., x2 = 25;
    
    [arrow moveToPoint:NSMakePoint(0, y1)];
    [arrow lineToPoint:NSMakePoint(x1, y1)];
    [arrow lineToPoint:NSMakePoint(x1, y2)];
    [arrow lineToPoint:NSMakePoint(x2, 0)];
    [arrow lineToPoint:NSMakePoint(x1, -y2)];
    [arrow lineToPoint:NSMakePoint(x1, -y1)];
    [arrow lineToPoint:NSMakePoint(0, -y1)];
    [arrow closePath];
    
    
    NSRect bounds = [arrow bounds];
    NSAffineTransform *at = [NSAffineTransform transform];
    
    [at translateXBy:-bounds.size.width/2. yBy:0];
    [arrow transformUsingAffineTransform:at];
    return arrow;
}
@end
