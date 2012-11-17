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

+ (void)moveTab:(ERPalettePanel *)palette fromView:(ERPaletteTabView *)origin toView:(ERPaletteTabView *)destination atLocation:(CGFloat)loc
{
    [palette retain];
    
    BOOL wasOpen = ([palette state] == ERPaletteOpened);
    
    if (wasOpen) {
        [palette setState:ERPaletteClosed animate:NO];
    }
    
    [origin removePalette:palette];
    [destination insertPalette:palette  atLocation:loc];
    
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
    
    [[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
    if (_highlight) {
        [[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] set];
    }
    [NSBezierPath fillRect:dirtyRect];
    
    if (_highlight) {
        [[NSColor whiteColor] set];
        [NSBezierPath fillRect:_draggingPositionMarker];
    }
}

@synthesize position = _position;

- (NSArray *)tabs
{
    return _tabs;
}

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
    CGFloat location;
    
    if ([_tabs count] > 0) {
        
        location = [[_tabs lastObject] locationInTabView]; // get the last element
        location += [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
    }else{
        location = 0;
    }
    
    [_tabs addObject:palette];
    [palette setTabView:self]; [palette setLocationInTabView:location];
    [palette setPalettePosition:[self position]];
    
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidClose:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidOpen:) name:ERPaletteDidOpenNotification object:palette];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidOpenNotification object:palette];

    // this also order the panel out
    [[self window] addChildWindow:palette ordered:NSWindowAbove];
    
    [self updateTabsLocations];
}

- (void)insertPalette:(ERPalettePanel *)palette atLocation:(CGFloat)loc
{
    int index;
    
    for (index = 0; index < [_tabs count]; index++) {
        if ([[_tabs objectAtIndex:index] locationInTabView] > loc) {
            break;
        }
    }
    [_tabs insertObject:palette atIndex:index];
    [palette setTabView:self]; [palette setLocationInTabView:loc];
    [palette setPalettePosition:[self position]];
    
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidClose:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:_holder selector:@selector(paletteDidOpen:) name:ERPaletteDidOpenNotification object:palette];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidCloseNotification object:palette];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteStateDidChange:) name:ERPaletteDidOpenNotification object:palette];
    
    // this also order the panel out
    [[self window] addChildWindow:palette ordered:NSWindowAbove];
    
    [self updateTabsLocations];
}

- (void)removePalette:(ERPalettePanel *)palette
{
    if ([_tabs containsObject:palette]) {
        [_tabs removeObject:palette];
        [palette setTabView:nil];
        
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

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
    [super resizeWithOldSuperviewSize:oldBoundsSize];
    [self updateTabsLocations];
}

- (void)sortPalettes
{
    [_tabs sortUsingSelector:@selector(compareLocationInTabView:)];
}

- (void)updateTabsLocations
{
    if ([_tabs count] == 0) {
        return;
    }
    [self sortPalettes];
    
    [[_tabs objectAtIndex:0] setLocationInTabView:MAX(0, [[_tabs objectAtIndex:0] locationInTabView])];
    for (int i = 0; i < ([_tabs count] - 1); i++) {
        ERPalettePanel *current = [_tabs objectAtIndex:i];
        ERPalettePanel *next = [_tabs objectAtIndex:i+1];
        
        CGFloat minLoc = [current locationInTabView] + [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
        if (minLoc > [next locationInTabView]) {
            [next setLocationInTabView:minLoc];
        }
    }
    
    
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
    CGFloat maxY = [self frame].size.height - [ERPaletteContentView paletteTitleSize];
    CGFloat y;
    
    for (ERPalettePanel *palette in _tabs) {
        y = maxY - [palette locationInTabView] - [ERPaletteContentView paletteTitleSize];
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
    }
}

- (void)_updateRightTabsLocations
{
    CGFloat maxY = [self frame].size.height - [ERPaletteContentView paletteTitleSize];
    CGFloat y;
    
    for (ERPalettePanel *palette in _tabs) {
        y = maxY - [palette locationInTabView] - [ERPaletteContentView paletteTitleSize];
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
    }
}

- (void)_updateDownTabsLocations
{
    CGFloat x;
    
    for (ERPalettePanel *palette in _tabs) {
        x = [palette locationInTabView] + [ERPaletteContentView paletteTitleSize];
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
    }
}

- (void)_updateUpTabsLocations
{
    CGFloat x;
    
    for (ERPalettePanel *palette in _tabs) {
        x = [palette locationInTabView] + [ERPaletteContentView paletteTitleSize];
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
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

- (NSRect)markerForTabLocation:(CGFloat)location
{
    if ([self position] == ERPalettePanelPositionUp || [self position] == ERPalettePanelPositionDown) {
        CGFloat x = location + 1.5*[ERPaletteContentView paletteTitleSize];
        return NSMakeRect(x, 0, 5., [self frame].size.height);
    }else{
        CGFloat y = location + 1.5*[ERPaletteContentView paletteTitleSize];
        y = NSMaxY([self bounds]) - y;
        
        return NSMakeRect(0, y, [self frame].size.width, 5.);
    }
}


#pragma mark Drag and Drop Palettes

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            _highlight = YES;

            NSPoint dropPoint = [self convertPoint:[sender draggingLocation] fromView:nil];
            CGFloat location;
            
            if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                location = NSMaxY([self bounds]) - dropPoint.y - [ERPaletteContentView paletteTitleSize]/2.;
            }else{
                location = dropPoint.x - [ERPaletteContentView paletteTitleSize]/2.;
            }
            location -= [ERPaletteContentView paletteTitleSize];

            _draggingPositionMarker = [self markerForTabLocation:location];
            
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

        [self setNeedsDisplay:YES];

        return NSDragOperationNone;
    }
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            _highlight = YES;

            NSPoint dropPoint = [self convertPoint:[sender draggingLocation] fromView:nil];
            CGFloat location;
            
            if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                location = NSMaxY([self bounds]) - dropPoint.y - [ERPaletteContentView paletteTitleSize]/2.;
            }else{
                location = dropPoint.x - [ERPaletteContentView paletteTitleSize]/2.;
            }
            location -= [ERPaletteContentView paletteTitleSize];
            
            _draggingPositionMarker = [self markerForTabLocation:location];
            
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
        
        if ([palette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            ERPaletteTabView *oldTabView = [palette tabView];

            NSPoint dropPoint = [self convertPoint:[sender draggingLocation] fromView:nil];
            CGFloat location;
            
            if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                location = NSMaxY([self bounds]) - dropPoint.y - [ERPaletteContentView paletteTitleSize]/2.;
            }else{
                location = dropPoint.x - [ERPaletteContentView paletteTitleSize]/2.;
            }
            location -= [ERPaletteContentView paletteTitleSize];
            

            if (oldTabView == self) { // we are just reordering tabs
                [palette setLocationInTabView:location];
                [self updateTabsLocations];
            }else{
                [ERPaletteTabView moveTab:palette fromView:oldTabView toView:self atLocation:location];
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
        
        if ([draggedPalette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            if (draggedPalette != palette) { // we are not the palette on itself, but we are on the header
                _highlight = YES;
 
                NSPoint dropPoint = [palette convertBaseToScreen:[sender draggingLocation]];
                dropPoint = [[self window] convertScreenToBase:dropPoint];
                dropPoint = [self convertPoint:dropPoint fromView:nil];
                
                CGFloat location;
                
                if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                    location = NSMaxY([self bounds]) - dropPoint.y ;
                }else{
                    location = dropPoint.x + [ERPaletteContentView paletteTitleSize];
                }
                location -= [ERPaletteContentView paletteTitleSize];
                
                
                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPaletteContentView paletteTitleSize]/2.) {
                    location = paletteLocation - [ERPaletteContentView paletteTitleSize] - [ERPaletteTabView tabMargin];
                }else{
                    location = paletteLocation + [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
                }
                
                _draggingPositionMarker = [self markerForTabLocation:location];

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
        
        if ([draggedPalette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            if (draggedPalette != palette) { // we are not the palette on itself, but we are on the header
                _highlight = YES;

                NSPoint dropPoint = [palette convertBaseToScreen:[sender draggingLocation]];
                dropPoint = [[self window] convertScreenToBase:dropPoint];
                dropPoint = [self convertPoint:dropPoint fromView:nil];
                
                CGFloat location;
                
                if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                    location = NSMaxY([self bounds]) - dropPoint.y ;
                }else{
                    location = dropPoint.x + [ERPaletteContentView paletteTitleSize];
                }
                location -= [ERPaletteContentView paletteTitleSize];
                
                
                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPaletteContentView paletteTitleSize]/2.) {
                    location = paletteLocation - [ERPaletteContentView paletteTitleSize] - [ERPaletteTabView tabMargin];
                }else{
                    location = paletteLocation + [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
                }
                _draggingPositionMarker = [self markerForTabLocation:location];

                [self setNeedsDisplay:YES];
                
                return NSDragOperationMove;
            }else{
                _highlight = NO;
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

        NSPoint mouseLocation = [palette convertBaseToScreen:[sender draggingLocation]];
        mouseLocation = [[self window] convertScreenToBase:mouseLocation];
        mouseLocation = [self convertPoint:mouseLocation fromView:nil];
        
        ERPalettePanel *draggedPalette = [sender draggingSource];
        
        if ([draggedPalette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            if (NSPointInRect(mouseLocation, [self bounds])) { // we are still on the tab view
                _highlight = YES;

                NSPoint dropPoint = [palette convertBaseToScreen:[sender draggingLocation]];
                dropPoint = [[self window] convertScreenToBase:dropPoint];
                dropPoint = [self convertPoint:dropPoint fromView:nil];
                
                CGFloat location;
                
                if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                    location = NSMaxY([self bounds]) - dropPoint.y ;
                }else{
                    location = dropPoint.x + [ERPaletteContentView paletteTitleSize];
                }
                location -= [ERPaletteContentView paletteTitleSize];
                
                
                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPaletteContentView paletteTitleSize]/2.) {
                    location = paletteLocation - [ERPaletteContentView paletteTitleSize] - [ERPaletteTabView tabMargin];
                }else{
                    location = paletteLocation + [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
                }
                
                _draggingPositionMarker = [self markerForTabLocation:location];

                [self setNeedsDisplay:YES];
                return;
            }
        }
    }
    _highlight = NO;
    [self setNeedsDisplay:YES];

}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender inPalette:(ERPalettePanel *)palette
{
    _highlight = NO;

    [self setNeedsDisplay:YES];
    
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *draggedPalette = [sender draggingSource];
        
        if ([draggedPalette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            if (draggedPalette != palette) { // we are not the palette on itself, but we are on the header
                
                ERPaletteTabView *oldTabView = [draggedPalette tabView];
                
                NSPoint dropPoint = [palette convertBaseToScreen:[sender draggingLocation]];
                dropPoint = [[self window] convertScreenToBase:dropPoint];
                dropPoint = [self convertPoint:dropPoint fromView:nil];
                
                CGFloat location;
                
                if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                    location = NSMaxY([self bounds]) - dropPoint.y ;
                }else{
                    location = dropPoint.x + [ERPaletteContentView paletteTitleSize];
                }
                location -= [ERPaletteContentView paletteTitleSize];
                

                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPaletteContentView paletteTitleSize]/2.) {
                    location = paletteLocation - [ERPaletteContentView paletteTitleSize] - [ERPaletteTabView tabMargin];
                }else{
                    location = paletteLocation + [ERPaletteContentView paletteTitleSize] + [ERPaletteTabView tabMargin];
                }

                if (oldTabView == self) { // we are just reordering tabs
                    [draggedPalette setLocationInTabView:location];
                    [self updateTabsLocations];
                }else{                    
                    [ERPaletteTabView moveTab:draggedPalette fromView:oldTabView toView:self atLocation:location];
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
