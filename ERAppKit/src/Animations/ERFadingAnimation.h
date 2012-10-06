//
//  ERFadingAnimation.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERGlobals.h>

/**
 \enum ERFadingAnimationType
 \brief Types of fading animations
 */
typedef enum{
    ERCustomAnimation = -1,     /**< Custom animation */
    ERFadeInAnimation = 0,      /**< Fade in animation: set alpha value to 1 */
    ERFadeOutAnimation = 1,     /**< Fade out animation: set alpha value to 0*/
    ERFadeBackAnimation = 2,    /**< Fade back animation: divides the alpha value by 2 */
    ERFadeFrontAnimation = 3    /**< Fade front animation: multiplies the alpha value by 2 */
} ERFadingAnimationType;

/**
 The ERFadingAnimation class offers a convienient way to create fading animations for windows.
 
 By default, these animations are on the NSAnimationNonblocking mode but you can configure this behavior by using NSAnimation methods.
 */
@interface ERFadingAnimation : NSAnimation
{
    @protected
    NSWindow *_window;
    ERFadingAnimationType _type;
}
@property (assign) NSWindow *window;            /** The window to be faded */
@property (assign) ERFadingAnimationType type;  /** The type of the animation. */

/**
 Initialize a new fading animation
 \param duration The number of seconds over which the animation occurs. Specifying a negative number raises an exception.
 \param animationCurve An NSAnimationCurve constant that describes the relative speed of the animation over its course; if it is zero, the default curve (NSAnimationEaseInOut) is used.
 \param target The window to be faded.
 \param aType The type of animation to be applied.
 
 \return An initialized ERFadingAnimation instance. Returns nil if the object could not be initialized.
 */
- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target animationType:(ERFadingAnimationType)aType;

/**
 Initialize a new fading animation
 \param duration The number of seconds over which the animation occurs. Specifying a negative number raises an exception.
 \param animationCurve An NSAnimationCurve constant that describes the relative speed of the animation over its course; if it is zero, the default curve (NSAnimationEaseInOut) is used.
 \param target The window to be faded.
 \param alpha The alpha value applied to the target window at the end of the animation.
 
 \return An initialized ERFadingAnimation instance. Returns nil if the object could not be initialized.
 
 \remark The type of this animation is ERCustomAnimation
 */
- (id)initWithDuration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve window:(NSWindow *)target endAlpha:(CGFloat)alpha;
@end
