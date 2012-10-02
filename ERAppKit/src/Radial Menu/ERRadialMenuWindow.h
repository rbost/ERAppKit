//
//  ERRadialMenuWindow.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ERRadialMenuWindow : NSPanel <NSAnimationDelegate>
{
    @private
//    NSViewAnimation *_fadeInAnimation;
//    NSViewAnimation *_fadeOutAnimation;
    NSAnimation *_currentAnimation;
}
- (id)initWithMenu:(NSMenu *)menu atLocation:(NSPoint)loc inView:(NSView *)view;
- (void)fadeIn:(id)sender;
- (void)fadeOut:(id)sender;
- (void)fadeBack:(id)sender;
- (void)fadeFront:(id)sender;
- (void)fadeToAlpha:(CGFloat)alpha;
@end
