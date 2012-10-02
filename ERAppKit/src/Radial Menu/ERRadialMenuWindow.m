//
//  ERRadialMenuWindow.m
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERRadialMenuWindow.h"

#import "ERRadialMenuView.h"

#import "ERFadingAnimation.h"

@interface ERRadialMenuWindow (PrivateAPI)

- (NSAnimation *)currentAnimation;
- (void)setCurrentAnimation:(NSAnimation *)anim;

@end



@implementation ERRadialMenuWindow
- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view
{
    ERRadialMenuView *menuView = [[ERRadialMenuView alloc] initWithMenu:menu];
    NSRect contentRect = NSZeroRect;
    
    if(view){
        loc = [view convertPoint:loc toView:nil];
        loc = [[view window] convertBaseToScreen:loc]; // ATTENTION: deprecated !
    }
    
    
    contentRect.size = [menuView frame].size;
    contentRect.origin = loc;
    contentRect.origin.x -= contentRect.size.width/2.;
    contentRect.origin.y -= contentRect.size.height/2.;
    
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
	
	[self setMovableByWindowBackground:NO];
	[self setLevel:NSTornOffMenuWindowLevel];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setHasShadow: YES];
	[self setShowsResizeIndicator:YES];
    [self setContentView:menuView]; [menuView release];
    [self setAlphaValue:0.];
    
    [self setAcceptsMouseMovedEvents:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:self];
    
    [self setAnimationBehavior:NSWindowAnimationBehaviorAlertPanel];
	return self;
}

- (void)dealloc
{
    [_currentAnimation stopAnimation];

    [super dealloc];
}


- (void)fadeIn:(id)sender
{
    ERFadingAnimation *animation = [[ERFadingAnimation alloc] initWithDuration:.2 animationCurve:NSAnimationLinear window:self animationType:ERFadeInAnimation];
    [animation setDelegate:self];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    
    [[self currentAnimation] stopAnimation];
    [animation startAnimation];
    [self setCurrentAnimation:animation];
    [animation release];
}

- (void)fadeOut:(id)sender
{
    ERFadingAnimation *animation = [[ERFadingAnimation alloc] initWithDuration:.2 animationCurve:NSAnimationLinear window:self animationType:ERFadeOutAnimation];
    [animation setDelegate:self];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    
    [[self currentAnimation] stopAnimation];
    [animation startAnimation];
    [self setCurrentAnimation:animation];
    [animation release];
}

- (void)fadeBack:(id)sender
{
    ERFadingAnimation *animation = [[ERFadingAnimation alloc] initWithDuration:.2 animationCurve:NSAnimationLinear window:self animationType:ERFadeBackAnimation];
    [animation setDelegate:self];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    
    [[self currentAnimation] stopAnimation];
    [animation startAnimation];
    [self setCurrentAnimation:animation];
    [animation release];
}

- (void)fadeFront:(id)sender
{
    ERFadingAnimation *animation = [[ERFadingAnimation alloc] initWithDuration:.2 animationCurve:NSAnimationLinear window:self animationType:ERFadeFrontAnimation];
    [animation setDelegate:self];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    
    [[self currentAnimation] stopAnimation];
    [animation startAnimation];
    [self setCurrentAnimation:animation];
    [animation release];
}

- (void)fadeToAlpha:(CGFloat)alpha
{
    ERFadingAnimation *animation = [[ERFadingAnimation alloc] initWithDuration:.2 animationCurve:NSAnimationLinear window:self endAlpha:alpha];
    [animation setDelegate:self];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    
    [[self currentAnimation] stopAnimation];
    [animation startAnimation];
    [self setCurrentAnimation:animation];
    [animation release];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
    [self setCurrentAnimation:nil];
    
    if ([(ERFadingAnimation *)animation type] == ERFadeOutAnimation) {
        [super close];
    }
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}
- (void)resignKeyWindow
{
    [super resignKeyWindow];
    [(ERRadialMenuView *)[self contentView] windowResign];
}

- (BOOL)isOpaque
{
	return NO;
}

- (NSAnimation *)currentAnimation
{
    return _currentAnimation;
}
- (void)setCurrentAnimation:(NSAnimation *)anim
{
    _currentAnimation = anim;
}


// override close method to perform a fade out

- (void)close
{
    [self fadeOut:self];
}

- (void)windowWillClose:(NSNotification *)note
{
//    [self fadeOut:self];
}

@end
