//
//  ERPaletteTab.h
//  ERAppKit
//
//  Created by Raphael Bost on 12/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERTimer.h>

@class ERPalettePanel;

@interface ERPaletteTab : NSButton
{
    NSPoint _draggingStartPoint;
    
    NSTrackingArea *_mouseOverArea;
    ERTimer *_mouseOverTimer;
}
@property (assign) ERPalettePanel *palette;
- (NSRect)drawnButtonRect;
@end
