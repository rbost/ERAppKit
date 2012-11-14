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

}
+ (CGFloat)paletteTitleSize;
- (NSRect)headerRect;
- (NSRect)tabRect;
//- (NSImage *)headerImage;
@end
