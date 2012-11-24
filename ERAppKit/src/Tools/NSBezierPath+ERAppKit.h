//
//  NSBezierPath+ERAppKit.h
//  ERAppKit
//
//  Created by Raphael Bost on 17/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum{
    ERNoneCorner = 0,
    ERUpperLeftCorner = 1,
    ERLowerLeftCorner = 1 << 1,
    ERUpperRightCorner = 1 << 2,
    ERLowerRightCorner = 1 << 3,
    ERAllCorners = ~0
}ERCorner;

@interface NSBezierPath (ERAppKit)
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect radius:(CGFloat)radius corners:(int)cornerMasks;
- (void)appendBezierPathWithRoundedRect:(NSRect)aRect radius:(CGFloat)radius corners:(int)cornerMasks;

+ (NSBezierPath *)centeredRightArrow;
@end
