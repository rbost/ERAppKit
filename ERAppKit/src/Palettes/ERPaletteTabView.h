//
//  ERPaletteTabView.h
//  ERAppKit
//
//  Created by Raphael Bost on 08/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERPalettePanel.h>
#import <ERAppKit/ERPaletteContentView.h>

@class ERPaletteHolderView;

@interface ERPaletteTabView : NSView
{
    BOOL _highlight;
    
    @protected
    NSMutableArray *_tabs;
    ERPaletteHolderView *_holder;
    ERPalettePanelPosition _position;
}
@property (readonly) NSArray *tabs;
@property (readonly) ERPalettePanelPosition position;
@property (readonly) ERPaletteHolderView *holder;
+ (CGFloat)tabMargin;
- (id)initWithHolder:(ERPaletteHolderView *)holder position:(ERPalettePanelPosition)position;
- (void)addPaletteWithContentView:(NSView *)contentView withTitle:(NSString *)paletteTitle;


- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;
- (void)draggingExited:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette;

@end
