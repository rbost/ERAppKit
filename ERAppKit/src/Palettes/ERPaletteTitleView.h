//
//  ERPaletteTitleView.h
//  ERAppKit
//
//  Created by Raphael Bost on 12/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERTimer.h>

@class ERPaletteButton;

@interface ERPaletteTitleView : NSView
{
    NSPoint _draggingStartPoint;
    ERPaletteButton *_closeButton;
    
    NSTrackingArea *_mouseOverArea;
    ERTimer *_mouseOverTimer;
}
- (void)updateCloseButtonPosition;
@end
