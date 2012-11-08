//
//  ERPaletteHolderView.h
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERPalettePanel.h>

@interface ERPaletteHolderView : NSView
{
    NSMutableArray *_leftPalettes;
    NSMutableArray *_rightPalettes;
    NSMutableArray *_upPalettes;
    NSMutableArray *_downPalettes;
}

- (void)addPaletteWithContentView:(NSView *)contentView withTitle:(NSString *)paletteTitle atPosition:(ERPalettePanelPosition)pos;
@end
