//
//  ERPaletteOpenPopup.h
//  ERAppKit
//
//  Created by Raphael Bost on 24/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERPalettePanel.h>

typedef enum {
    ERPaletteHorizontalOrientation = 0,
    ERPaletteVerticalOrientation
}ERPalettePopupOrientation;

@interface ERPaletteOpenPopup : NSPanel
+ (void)popupWithOrientation:(ERPalettePopupOrientation)orientation palettePanel:(ERPalettePanel *)palette atLocation:(NSPoint)screenLocation;
- (id)initWithOrientation:(ERPalettePopupOrientation)orientation palettePanel:(ERPalettePanel *)palette atLocation:(NSPoint)screenLocation;
@end
