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

+ (void)moveTab:(ERPalettePanel *)palette fromView:(ERPaletteTabView *)origin toView:(ERPaletteTabView *)destination
{
    [palette retain];
    
    [origin removePalette:palette];
    [destination addPalette:palette];
    [palette updateFrameSizeAndContentPlacement];
    [[palette contentView] setNeedsDisplay:YES];
    
    [palette release];
}

+ (void)moveTab:(ERPalettePanel *)palette fromView:(ERPaletteTabView *)origin toView:(ERPaletteTabView *)destination atIndex:(NSUInteger)index
{
    [palette retain];
    
    BOOL wasOpen = ([palette state] == ERPaletteOpened);
    
    if (wasOpen) {
        [palette setState:ERPaletteClosed animate:NO];
    }
    
    [origin removePalette:palette];
    [destination insertPalette:palette  atIndex:index];
    
    if (wasOpen) {
        [palette openInBestDirection:nil];
    }
//    [palette updateFrameSizeAndContentPlacement];
    [[palette contentView] setNeedsDisplay:YES];
    
    [palette release];
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
    
    _draggingPosition = -1;
    
    [self registerForDraggedTypes:[NSArray arrayWithObject:ERPalettePboardType]];
    
    return self;
}

- (void)dealloc
{
    [_tabs makeObjectsPerformSelector:@selector(setTabView:) withObject:nil];
    [_tabs release];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    
    if (_draggingPosition != -1) {
        [[NSColor yellowColor] set];
        [NSBezierPath fillRect:_draggingPositionMarker];
    }
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
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidOpenNotification object:palette];

    // this also order the panel out
    [[self window] addChildWindow:palette ordered:NSWindowAbove];
    
    [self updateTabsLocations];
}

- (void)insertPalette:(ERPalettePanel *)palette atIndex:(NSUInteger)index
{
    [_tabs insertObject:palette atIndex:index];
    [palette setTabView:self];
    [palette setPalettePosition:[self position]];
    
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidClose:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidOpen:) name:ERPaletteDidOpenNotification object:palette];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidOpenNotification object:palette];
    
    // this also order the panel out
    [[self window] addChildWindow:palette ordered:NSWindowAbove];
    
    [self updateTabsLocations];
}

- (void)movePalette:(ERPalettePanel *)palette toIndex:(NSUInteger)index
{
    // index is the desired position of the palette in the old tab array
    NSUInteger oldIndex = [_tabs indexOfObject:palette];
    
    if (oldIndex == NSNotFound) {
        NSLog(@"%@ is not is the tabs array",palette);
        return;
    }
    
    if (oldIndex > index) {
        // this is easy, we can just remove and add the palette
        
        [palette retain];
        [_tabs removeObjectAtIndex:oldIndex];
        [_tabs insertObject:palette atIndex:index];
        [palette release];
        
        [self updateTabsLocations];
    }
    
    if (oldIndex < index) {
        // when we will remove the palette from the array, the indexes will be set off by 1
        [palette retain];
        [_tabs removeObjectAtIndex:oldIndex];
        [_tabs insertObject:palette atIndex:index-1];
        [palette release];
        
        [self updateTabsLocations];
    }

}
- (void)removePalette:(ERPalettePanel *)palette
{
    if ([_tabs containsObject:palette]) {
        [_tabs removeObject:palette];
        [[NSNotificationCenter defaultCenter] removeObserver:_holder name:ERPaletteDidCloseNotification object:palette];
        [[NSNotificationCenter defaultCenter] removeObserver:_holder name:ERPaletteDidOpenNotification object:palette];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:ERPaletteDidCloseNotification object:palette];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ERPaletteDidOpenNotification object:palette];

        [[self window] removeChildWindow:palette];
        [self updateTabsLocations];
    }
}

- (void)paletteStateDidChange:(NSNotification *)note
{
//    NSLog(@"palette state changed");
//    [self updateTabsLocations];
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
        y -= [ERPaletteContentView paletteTitleSize];
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
        
        y -= [ERPaletteTabView tabMargin];
    }
}

- (void)_updateRightTabsLocations
{
    CGFloat y = [self frame].size.height - [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _tabs) {
        y -= [ERPaletteContentView paletteTitleSize];
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
        
        y -= [ERPaletteTabView tabMargin];
    }
}

- (void)_updateDownTabsLocations
{
    CGFloat x = [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _tabs) {
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];

        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
        x += [ERPaletteContentView paletteTitleSize];
        x += [ERPaletteTabView tabMargin];
    }
}

- (void)_updateUpTabsLocations
{
    CGFloat x = [ERPaletteContentView paletteTitleSize];
    
    for (ERPalettePanel *palette in _tabs) {
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
        x += [ERPaletteContentView paletteTitleSize];
        x += [ERPaletteTabView tabMargin];
    }
}

- (int)tabPositionForMouseLocation:(NSPoint)location
{
    if ([self position] == ERPalettePanelPositionUp || [self position] == ERPalettePanelPositionDown) {
        CGFloat xAccumulator = [ERPaletteContentView paletteTitleSize];
        int i;
        for (i = 0; i < [_tabs count]; i++) {
            xAccumulator += [ERPaletteContentView paletteTitleSize];
            if (location.x < xAccumulator) {
                break;
            }else{
                xAccumulator += [ERPaletteTabView tabMargin];
            }
        }
        return i;
    }else{
        CGFloat yAccumulator = NSMaxY([self bounds]) - [ERPaletteContentView paletteTitleSize];
        int i;
        
        for (i = 0; i < [_tabs count]; i++) {
            yAccumulator -= [ERPaletteContentView paletteTitleSize];
            if (location.y > yAccumulator) {
                break;
            }else{
                yAccumulator -= [ERPaletteTabView tabMargin];
            }
        }
        return i;
    }
}

- (NSRect)markerForTabPosition:(int)position
{
    if (position == -1) {
        return NSZeroRect;
    }
    if ([self position] == ERPalettePanelPositionUp || [self position] == ERPalettePanelPositionDown) {
        CGFloat xAccumulator = [ERPaletteContentView paletteTitleSize] - [ERPaletteTabView tabMargin];
        
        for (int i = 0; i < [_tabs count] && i < position; i++) {
            xAccumulator += [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
        }
        return NSMakeRect(xAccumulator, 0, [ERPaletteTabView tabMargin], [self frame].size.height);
    }else{
        CGFloat yAccumulator = [self bounds].size.height - [ERPaletteContentView paletteTitleSize];
        
        for (int i = 0; i < [_tabs count] && i < position; i++) {
            yAccumulator -= [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
        }
        return NSMakeRect(0, yAccumulator, [self frame].size.width, [ERPaletteTabView tabMargin]);
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder]) { // drag authorized only inside the same holder view
            _highlight = YES;
            _draggingPosition = [self tabPositionForMouseLocation:[sender draggingLocation]];
            _draggingPositionMarker = [self markerForTabPosition:_draggingPosition];
            
            [self setNeedsDisplay:YES];
            
            return NSDragOperationMove;
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if (!NSPointInRect([self convertPoint:[sender draggingLocation] fromView:nil], [self bounds])) {
        _highlight = NO;
        _draggingPosition = -1;

        [self setNeedsDisplay:YES];

        return NSDragOperationNone;
    }
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder]) { // drag authorized only inside the same holder view
            _highlight = YES;
            _draggingPosition = [self tabPositionForMouseLocation:[self convertPoint:[sender draggingLocation] fromView:nil]];
            _draggingPositionMarker = [self markerForTabPosition:_draggingPosition];
            [self setNeedsDisplay:YES];
            
            return NSDragOperationMove;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    _highlight = NO;
    _draggingPosition = -1;

    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    int dropPosition = _draggingPosition;
    _highlight = NO;
    _draggingPosition = -1;

    [self setNeedsDisplay:YES];

    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder]) { // drag authorized only inside the same holder view
            ERPaletteTabView *oldTabView = [palette tabView];

            if (oldTabView == self) { // we are just reordering tabs
                if (dropPosition != [_tabs indexOfObject:palette]) { // we are actually reordering tabs
                    [self movePalette:palette toIndex:dropPosition];
                }else{
                    return NO;
                }
            }else{
                [ERPaletteTabView moveTab:palette fromView:oldTabView toView:self atIndex:dropPosition];
            }
            return YES;
        }
    }

    return NO;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *draggedPalette = [sender draggingSource];
        
        if ([draggedPalette holder] == [self holder]) { // drag authorized only inside the same holder view
            if (draggedPalette != palette) { // we are not the palette on itself, but we are on the header
                _highlight = YES;
                _draggingPosition = (int)[_tabs indexOfObject:palette];
                _draggingPositionMarker = [self markerForTabPosition:_draggingPosition];

                [self setNeedsDisplay:YES];
                
                return NSDragOperationMove;
            }
        }

    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *draggedPalette = [sender draggingSource];
        
        if ([draggedPalette holder] == [self holder]) { // drag authorized only inside the same holder view
            if (draggedPalette != palette) { // we are not the palette on itself, but we are on the header
                _highlight = YES;
                _draggingPosition = (int)[_tabs indexOfObject:palette];
                _draggingPositionMarker = [self markerForTabPosition:_draggingPosition];
                [self setNeedsDisplay:YES];
                
                return NSDragOperationMove;
            }else{
                _highlight = NO;
                _draggingPosition = -1;
                _draggingPositionMarker = [self markerForTabPosition:_draggingPosition];
                [self setNeedsDisplay:YES];

                return NSDragOperationNone;
            }
        }
        
    }
    return NSDragOperationNone;    
}

- (void)draggingExited:(id<NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {

        NSPoint location = [palette convertBaseToScreen:[sender draggingLocation]];
        location = [[self window] convertScreenToBase:location];
        location = [self convertPoint:location fromView:nil];
        
        ERPalettePanel *draggedPalette = [sender draggingSource];
        
        if ([draggedPalette holder] == [self holder]) { // drag authorized only inside the same holder view
            if (NSPointInRect(location, [self bounds])) { // we are still on the tab view
                _highlight = YES;
                _draggingPosition = [self tabPositionForMouseLocation:location];
                _draggingPositionMarker = [self markerForTabPosition:_draggingPosition];
                
                [self setNeedsDisplay:YES];
                return;
            }
        }
    }
    _draggingPosition = -1;
    _highlight = NO;
    [self setNeedsDisplay:YES];

}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette
{
    int dropPosition = _draggingPosition;

    _highlight = NO;
    _draggingPosition = -1;

    [self setNeedsDisplay:YES];
    
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *draggedPalette = [sender draggingSource];
        
        if ([draggedPalette holder] == [self holder]) { // drag authorized only inside the same holder view
            if (draggedPalette != palette) { // we are not the palette on itself, but we are on the header
                
                ERPaletteTabView *oldTabView = [draggedPalette tabView];
                
                if (oldTabView == self) { // we are just reordering tabs
                    if (dropPosition != [_tabs indexOfObject:draggedPalette]) { // we are actually reordering tabs
                        [self movePalette:draggedPalette toIndex:dropPosition];
                    }else{
                        return NO;
                    }
                }else{
                    [ERPaletteTabView moveTab:draggedPalette fromView:oldTabView toView:self atIndex:dropPosition];
                }

                return YES;
            }else{
                return NO;
            }
        }
        
    }
    return NO;
}

@end
