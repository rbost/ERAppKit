//
//  ERPaletteContentView.h
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ERPaletteContentView : NSView
{
    @private
    NSPoint _draggingStartPoint;
    NSPoint _oldFrameOrigin;
    BOOL _didDrag;
}
+ (CGFloat)paletteTitleSize;
- (NSRect)headerRect;
@end
