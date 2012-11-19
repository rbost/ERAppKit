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
@end
