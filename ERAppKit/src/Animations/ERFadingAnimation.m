//
//  ERFadingAnimation.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERFadingAnimation.h"

@interface ERFadingAnimation ()
@property (assign) CGFloat startAlpha;
@property (assign) CGFloat endAlpha;
@end

@implementation ERFadingAnimation
- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target animationType:(ERFadingAnimationType)aType
{
    self = [super initWithDuration:duration animationCurve:animationCurve];
    
    [self setWindow:target];
    [self setType:aType];
    
    
    switch ([self type]) {
        case ERFadeInAnimation:
            startAlpha = [[self window] alphaValue]; endAlpha = 1.;
            break;
            
        case ERFadeOutAnimation:
            startAlpha = [[self window] alphaValue]; endAlpha = 0.;
            break;
            
        case ERFadeFrontAnimation: // multiply the alpha by 2
            startAlpha = [[self window] alphaValue];
            endAlpha = MIN(2*startAlpha, 1.);
            break;
            
        case ERFadeBackAnimation: // divide the alpha by 2
            startAlpha = [[self window] alphaValue];
            endAlpha = MAX(0., 0.5*startAlpha);
            break;
            
        default:
            startAlpha = 1.; endAlpha = 1.;
            break;
    }
    
    [self setAnimationBlockingMode:NSAnimationNonblocking];
    return self;
}

- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target endAlpha:(CGFloat)alpha
{
    self = [super initWithDuration:duration animationCurve:animationCurve];
    
    [self setWindow:target];
    [self setType:ERCustomAnimation];
    
    startAlpha = [[self window] alphaValue];
    endAlpha = alpha;
    
    [self setAnimationBlockingMode:NSAnimationNonblocking];
    return self;    
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [super setCurrentProgress:progress];
    
    [[self window] setAlphaValue:progress*endAlpha + (1-progress)*startAlpha]; // linear animation
}

@synthesize startAlpha, endAlpha;

@end
