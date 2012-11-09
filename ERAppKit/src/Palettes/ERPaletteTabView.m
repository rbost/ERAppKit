//
//  ERPaletteTabView.m
//  ERAppKit
//
//  Created by Raphael Bost on 08/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteTabView.h"

#import <ERAppKit/ERPaletteHolderView.h>

@implementation ERPaletteTabView

static CGFloat __tabMargin = 5.;
+ (CGFloat)tabMargin
{
    return __tabMargin;
}

- (id)initWithHolder:(ERPaletteHolderView *)holder position:(ERPalettePanelPosition)position
{
    NSRect frame;
    
    switch (position) {
        case ERPalettePanelPositionLeft:
            frame = NSMakeRect(0, 0, [ERPaletteContentView paletteTitleSize], [holder frame].size.height);
            break;
            
        case ERPalettePanelPositionDown:
            frame = NSMakeRect(0, 0, [holder frame].size.width, [ERPaletteContentView paletteTitleSize]);
            break;
            
        case ERPalettePanelPositionRight:
            frame = NSMakeRect([holder frame].size.width - [ERPaletteContentView paletteTitleSize], 0, [ERPaletteContentView paletteTitleSize], [holder frame].size.height);
            break;
            
        case ERPalettePanelPositionUp:
            frame = NSMakeRect(0, [holder frame].size.height - [ERPaletteContentView paletteTitleSize], [holder frame].size.width, [ERPaletteContentView paletteTitleSize]);
            break;
            
        default:
            frame = NSZeroRect;
            break;
    }
    
    self = [super initWithFrame:frame];
    
    _tabs = [[NSMutableArray alloc] init];
    _position = position;
    _holder = holder;
    
    [self registerForDraggedTypes:[NSArray arrayWithObject:ERPalettePboardType]];
    
    return self;
}

- (void)dealloc
{
    [_tabs makeObjectsPerformSelector:@selector(setTabView:) withObject:nil];
    [_tabs release];
    
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    [[NSColor redColor] set];
    if (_highlight) {
        [[NSColor blueColor] set];
    }
    [NSBezierPath fillRect:dirtyRect];
}

@synthesize position = _position;
@synthesize tabs = _tabs;
@synthesize holder = _holder;

- (void)addPaletteWithContentView:(NSView *)contentView withTitle:(NSString *)paletteTitle
{
    ERPalettePanel *palette = [[ERPalettePanel alloc] initWithContent:contentView position:[self position]];
    [palette setTitle:paletteTitle];
    
    [palette setState:ERPaletteClosed animate:NO];
    
    [self addPalette:palette];
    [palette release];
}

- (void)addPalette:(ERPalettePanel *)palette
{
    [_tabs addObject:palette];
    [palette setTabView:self];
    [palette setPalettePosition:[self position]];
    
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidClose:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidOpen:) name:ERPaletteDidOpenNotification object:palette];
    
    // this also order the panel out
    [[self window] addChildWindow:palette ordered:NSWindowAbove];
    
    [self updateTabsLocations];
}

- (void)removePalette:(ERPalettePanel *)palette
{
    if ([_tabs containsObject:palette]) {
        [_tabs removeObject:palette];
        [[NSNotificationCenter defaultCenter] removeObserver:_holder name:ERPaletteDidCloseNotification object:palette];
        [[NSNotificationCenter defaultCenter] removeObserver:_holder name:ERPaletteDidOpenNotification object:palette];
        [[self window] removeChildWindow:palette];
        [self updateTabsLocations];
    }
}

- (void)updateTabsLocations
{
    switch ([self position]) {
        case ERPalettePanelPositionRight:
            [self _updateRightTabsLocations];
            break;
            
        case ERPalettePanelPositionLeft:
            [self _updateLeftTabsLocations];
            break;
            
        case ERPalettePanelPositionUp:
            [self _updateUpTabsLocations];
            break;
            
        case ERPalettePanelPositionDown:
            [self _updateDownTabsLocations];
            break;
            
        default:
            break;
    }
 
}


- (void)_updateLeftTabsLocations
{
    CGFloat y = [self frame].size.height - [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _tabs) {
        NSRect paletteFrame = [palette frame];
        y -= paletteFrame.size.height;
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        if ([palette state] == ERPaletteOpened && [palette openingDirection] == ERPaletteOutsideOpeningDirection) {
            frameOrigin.x -= [[palette content] frame].size.width;
        }
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        
        y -= [ERPaletteTabView tabMargin];
    }
}

- (void)_updateRightTabsLocations
{
    CGFloat y = [self frame].size.height - [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _tabs) {
        NSRect paletteFrame = [palette frame];
        y -= paletteFrame.size.height;
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        if ([palette state] == ERPaletteOpened && [palette openingDirection] == ERPaletteInsideOpeningDirection) {
            frameOrigin.x -= [[palette content] frame].size.width;
        }

        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        
        y -= [ERPaletteTabView tabMargin];
    }
}

- (void)_updateDownTabsLocations
{
    CGFloat x = [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _tabs) {
        NSRect paletteFrame = [palette frame];
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];

        if ([palette state] == ERPaletteOpened && [palette openingDirection] == ERPaletteOutsideOpeningDirection) {
            frameOrigin.y -= [[palette content] frame].size.height;
        }

        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        x += paletteFrame.size.width;
        x += [ERPaletteTabView tabMargin];
    }
}

- (void)_updateUpTabsLocations
{
    CGFloat x = [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _tabs) {
        NSRect paletteFrame = [palette frame];
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];

        if ([palette state] == ERPaletteOpened && [palette openingDirection] == ERPaletteInsideOpeningDirection) {
            frameOrigin.y -= [[palette content] frame].size.height;
        }

        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setFrameOrigin:frameOrigin];
        x += paletteFrame.size.width;
        x += [ERPaletteTabView tabMargin];
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder]) { // drag authorized only inside the same holder view
            _highlight = YES;
            [self setNeedsDisplay:YES];
            
            return NSDragOperationMove;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    _highlight = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    _highlight = NO;
    [self setNeedsDisplay:YES];

    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder] && [palette tabView] != self) { // drag authorized only inside the same holder view and the tab is not already here
            ERPaletteTabView *oldTabView = [palette tabView];
            
            [palette retain];
            [oldTabView removePalette:palette];
            [self addPalette:palette];
            [palette updateFrameSizeAndContentPlacement];
            [[palette contentView] setNeedsDisplay:YES];
            return YES;
        }
    }

    return NO;
}
@end
