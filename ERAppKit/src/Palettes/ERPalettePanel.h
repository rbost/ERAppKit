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
    ERPaletteOpenedInside,
    ERPaletteOpenedOutside
}ERPaletteState;

@interface ERPalettePanel : NSPanel
{
    ERPalettePanelPosition _palettePosition;
    ERPaletteState _state;
    
    NSView *_content;
}
@property (assign) ERPalettePanelPosition palettePosition;
@property (assign) ERPaletteState state;

- (id)initWithContent:(NSView *)content position:(ERPalettePanelPosition)pos;

- (IBAction)toggleCollapse:(id)sender;
- (NSView *)content;
- (void)setContent:(NSView *)newContent;

- (void)setState:(ERPaletteState)state animate:(BOOL)animate;
@end


extern NSString *ERPaletteDidCloseNotification;
extern NSString *ERPaletteDidOpenNotification;

extern NSString *ERPaletteNewFrameKey;
