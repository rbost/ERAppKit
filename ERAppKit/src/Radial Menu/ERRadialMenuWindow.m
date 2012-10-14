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
#import "ERGeometry.h"

#define ERMenuXMargin 5.
#define ERMenuYMargin 5.


@interface ERRadialMenuWindow (PrivateAPI)

- (NSAnimation *)currentAnimation;
- (void)setCurrentAnimation:(NSAnimation *)anim;

- (void)_initWindowWithMenuView:(ERRadialMenuView *)menuView atLocation:(NSPoint)loc;

@end



@implementation ERRadialMenuWindow
- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view menuStyle:(ERMenuStyle)style
{
    // first of all, intialize the menu view which will be our content view
    // it takes care about displaying the menu and calculating the necessary content frame we need
    ERRadialMenuView *menuView = [[ERRadialMenuView alloc] initWithMenu:menu style:style];
    
    // get the location on the screen
    if(view){
        loc = [view convertPoint:loc toView:nil];
        NSRect convertRect; convertRect.origin = loc; convertRect.size = NSZeroSize;
        loc = [[view window] convertRectToScreen:convertRect].origin;
    }
    
    [self _initWindowWithMenuView:menuView atLocation:loc];
    
	return self;
}

- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view menuStyle:(ERMenuStyle)style direction:(CGFloat)direction
{
    // first of all, intialize the menu view which will be our content view
    // it takes care about displaying the menu and calculating the necessary content frame we need
    ERRadialMenuView *menuView = [[ERRadialMenuView alloc] initWithMenu:menu style:style direction:direction];
    
    // get the location on the screen
    if(view){
        loc = [view convertPoint:loc toView:nil];
        NSRect convertRect; convertRect.origin = loc; convertRect.size = NSZeroSize;
        loc = [[view window] convertRectToScreen:convertRect].origin;
    }
    
    [self _initWindowWithMenuView:menuView atLocation:loc];
    
	return self;    
}

- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view
{
    return [self initWithMenu:menu atLocation:loc inView:view menuStyle:ERDefaultMenuStyle];
}

- (void)_initWindowWithMenuView:(ERRadialMenuView *)menuView atLocation:(NSPoint)loc
{
    NSRect contentRect = NSZeroRect;
    
    // set the size of the content rect
    contentRect.size = [menuView frame].size;
    // and center it on the location
    contentRect.origin = loc;
    contentRect.origin.x -= contentRect.size.width/2.;
    contentRect.origin.y -= contentRect.size.height/2.;
    
    // be sure we use a par of the screen which is visible
    contentRect = ERPutRectInRectWithMargin(contentRect, [[NSScreen mainScreen] visibleFrame],ERMenuXMargin,ERMenuYMargin);
    
    // now, let's create ourself ...
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
	
	[self setMovableByWindowBackground:NO];
	[self setLevel:NSTornOffMenuWindowLevel];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setHasShadow: YES];
	[self setShowsResizeIndicator:YES];
    
    // set the content view
    [self setContentView:menuView]; [menuView release];
    // hide ourself; we will we showed when ordered front
    [self setAlphaValue:0.];
    // to have a pretty animation when opening the menu
    [self setAnimationBehavior:NSWindowAnimationBehaviorAlertPanel];
    
    
    // we accept mouse moved event to track mouse position on the menu
    [self setAcceptsMouseMovedEvents:YES];
   
}
- (void)dealloc
{
    // stop the current animation 
    [_currentAnimation stopAnimation];

    [super dealloc];
}

// launch animation when opening the menu
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

// launch animation when closing the menu
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

// launch animation when opening a submenu
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

// launch animation when closing a submenu
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

// launch animation to fade to a specific opacity
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
    // we have to override this method as the implementation of NSWindow return NO when the window has NSBorderlessWindowMask
    return YES;
}
- (void)resignKeyWindow
{
    // override this to catch clicks outside the menu
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
@end
