//
//  ERPalettePanel.h
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum{
    ERPalettePanelPositionUp = 0,
    ERPalettePanelPositionRight,
    ERPalettePanelPositionDown,
    ERPalettePanelPositionLeft
}ERPalettePanelPosition;

typedef enum{
    ERPaletteClosed = 0,
    ERPaletteOpened
}ERPaletteState;

typedef enum {
    ERPaletteInsideOpeningDirection = 10,
    ERPaletteOutsideOpeningDirection
}ERPaletteOpeningDirection;

@class ERPaletteTabView, ERPaletteHolderView;

@interface ERPalettePanel : NSPanel
{
    ERPalettePanelPosition _palettePosition;
    ERPaletteState _state;
    ERPaletteOpeningDirection _openingDirection;
    
    NSView *_content;
    ERPaletteTabView *_tabView;
}
@property (assign) ERPalettePanelPosition palettePosition;
@property (assign) ERPaletteState state;
@property (assign) ERPaletteOpeningDirection openingDirection;
@property (assign) ERPaletteTabView *tabView;
@property (readonly) ERPaletteHolderView *holder;

- (id)initWithContent:(NSView *)content position:(ERPalettePanelPosition)pos;

- (IBAction)toggleCollapse:(id)sender;
- (NSView *)content;
- (void)setContent:(NSView *)newContent;

- (void)setState:(ERPaletteState)state animate:(BOOL)animate;
- (void)updateAutoresizingMask;
- (void)updateFrameSizeAndContentPlacement;

- (ERPalettePanelPosition)effectiveHeaderPosition;

- (NSRect)headerRect;
@end


extern NSString *ERPaletteDidCloseNotification;
extern NSString *ERPaletteDidOpenNotification;

extern NSString *ERPaletteNewFrameKey;

extern NSString *ERPalettePboardType;