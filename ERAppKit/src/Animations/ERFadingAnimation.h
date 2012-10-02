//
//  ERFadingAnimation.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum{
    ERCustomAnimation = -1,
    ERFadeInAnimation = 0,
    ERFadeOutAnimation = 1,
    ERFadeBackAnimation = 2,
    ERFadeFrontAnimation = 3
} ERFadingAnimationType;

@interface ERFadingAnimation : NSAnimation
@property (assign) NSWindow *window;
@property (assign) int type;

- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target animationType:(ERFadingAnimationType)aType;
- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target endAlpha:(CGFloat)alpha;
@end
