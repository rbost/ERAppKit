//
//  ERRadialMenuWindow.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERGlobals.h>

@interface ERRadialMenuWindow : NSPanel <NSAnimationDelegate>
{
    @private
    NSAnimation *_currentAnimation;
}

- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view menuStyle:(ERMenuStyle)style;
- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view menuStyle:(ERMenuStyle)style direction:(CGFloat)direction;
- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view;
- (void)fadeIn:(id)sender;
- (void)fadeOut:(id)sender;
- (void)fadeBack:(id)sender;
- (void)fadeFront:(id)sender;
- (void)fadeToAlpha:(CGFloat)alpha;
@end
