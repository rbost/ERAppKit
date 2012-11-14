//
//  ERPaletteTab.h
//  ERAppKit
//
//  Created by Raphael Bost on 12/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ERPalettePanel;

@interface ERPaletteTab : NSButton
{
    NSPoint _draggingStartPoint;;
    BOOL _didDrag;
}
@property (assign) ERPalettePanel *palette;
@end
