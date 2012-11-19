//
//  ERPalettePanel.h
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ERAppKit/ERPaletteTabButton.h>

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
@class ERPaletteTitleView, ERPaletteTab;

@interface ERPalettePanel : NSPanel <NSDraggingSource>
{
    ERPalettePanelPosition _palettePosition;
    ERPaletteState _state;
    ERPaletteOpeningDirection _openingDirection;
    ERPaletteOpeningDirection _preferedOpeningDirection;
    
    NSView *_content;
    ERPaletteTabView *_tabView;
    
    ERPaletteTitleView *_titleView;
    ERPaletteTab *_tabButton;
     
    NSPoint _dragStartingPoint;
}
@property (assign) ERPalettePanelPosition palettePosition;
@property (assign) ERPaletteState state;
@property (assign) ERPaletteOpeningDirection openingDirection;
@property (assign) ERPaletteOpeningDirection preferedOpeningDirection;
@property (assign) ERPaletteTabView *tabView;
@property (readonly) ERPaletteHolderView *holder;

@property (retain) NSImage *icon;

@property (assign) CGFloat locationInTabView;

+(CGFloat)tabWidth;
+(CGFloat)tabHeight;
+ (NSSize)tabSizeForPanelPosition:(ERPalettePanelPosition)pos;

- (id)initWithContent:(NSView *)content position:(ERPalettePanelPosition)pos;

- (IBAction)collapse:(id)sender;
- (IBAction)openInBestDirection:(id)sender;
- (IBAction)toggleCollapse:(id)sender;
- (NSView *)content;
- (void)setContent:(NSView *)newContent;
- (NSRect)contentScreenFrame;

- (void)setTabOrigin:(NSPoint)tabOrigin;

- (void)setState:(ERPaletteState)state animate:(BOOL)animate;
- (void)updateAutoresizingMask;
- (void)updateFrameSizeAndContentPlacement;

- (ERPalettePanelPosition)effectiveHeaderPosition;

- (NSRect)headerRect;
- (NSRect)tabRect;

- (NSSize)paletteContentSize;
- (NSRect)paletteContentFrame;
- (NSSize)openedPaletteSize;
- (NSSize)closedPaletteSize;
- (NSSize)paletteSize;

- (BOOL)isAttached;


- (NSComparisonResult)compareLocationInTabView:(ERPalettePanel *)palette;
@end


extern NSString *ERPaletteDidCloseNotification;
extern NSString *ERPaletteDidOpenNotification;

extern NSString *ERPaletteNewFrameKey;

extern NSString *ERPalettePboardType;