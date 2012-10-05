//
//  ERFadingAnimation.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERGlobals.h>

@interface ERFadingAnimation : NSAnimation
{
    @protected
    NSWindow *_window;
    ERFadingAnimationType _type;
}
@property (assign) NSWindow *window;
@property (assign) ERFadingAnimationType type;

- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target animationType:(ERFadingAnimationType)aType;
- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target endAlpha:(CGFloat)alpha;
@end
