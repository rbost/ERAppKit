//
//  ERPaletteTabView.m
//  ERAppKit
//
//  Created by Raphael Bost on 08/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteTabView.h"

#import <ERAppKit/ERPaletteHolderView.h>
#import <ERAppKit/ERPaletteContentView.h>

#import <ERAppKit/NSBezierPath+ERAppKit.h>

#import <QuartzCore/QuartzCore.h>

@implementation ERPaletteTabView

static CGFloat __tabMargin = -10.;
+ (CGFloat)tabMargin
{
    return __tabMargin;
}

static CGFloat __barThickness = 30.;
+ (CGFloat)barThickness
{
    return __barThickness;
}

+ (CGFloat)barExtremitiesMargins
{
    return 0;
    return [self barThickness];
}

+ (void)moveTab:(ERPalettePanel *)palette fromView:(ERPaletteTabView *)origin toView:(ERPaletteTabView *)destination
{
    [palette retain];
    
    [origin removePalette:palette];
    [destination addPalette:palette];
    [palette updateContentPlacement];
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

    [[palette contentView] setNeedsDisplay:YES];
    
    [palette release];
}

+ (id)defaultAnimationForKey:(NSString *)key {
    if ([key isEqualToString:@"barFrame"]) {
        return [CABasicAnimation animation];
    } else {
        return [super defaultAnimationForKey:key];
    }
}

- (id)initWithHolder:(ERPaletteHolderView *)holder position:(ERPalettePanelPosition)position
{
    NSRect frame;
    CGFloat barThickness = [ERPaletteTabView barThickness];
    
    switch (position) {
        case ERPalettePanelPositionLeft:
            frame = NSMakeRect(0, barThickness, barThickness, [holder frame].size.height-2*barThickness);
            break;
            
        case ERPalettePanelPositionDown:
            frame = NSMakeRect(barThickness, 0, [holder frame].size.width-2*barThickness, barThickness);
            break;
            
        case ERPalettePanelPositionRight:
            frame = NSMakeRect([holder frame].size.width - barThickness, barThickness, barThickness, [holder frame].size.height - 2*barThickness);
            break;
            
        case ERPalettePanelPositionUp:
            frame = NSMakeRect(barThickness, [holder frame].size.height - barThickness, [holder frame].size.width - 2*barThickness, barThickness);
            break;
            
        default:
            frame = NSZeroRect;
            break;
    }
    
    self = [self initWithHolder:holder frame:frame position:position];
    
    return self;
}

- (id)initWithHolder:(ERPaletteHolderView *)holder frame:(NSRect)frame position:(ERPalettePanelPosition)position
{    
    self = [super initWithFrame:frame];
    
    _tabs = [[NSMutableArray alloc] init];
    _position = position;
    _holder = holder;
    
    [self registerForDraggedTypes:[NSArray arrayWithObject:ERPalettePboardType]];
    
    [self setBarFrame:[self bounds]];
    
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
    int corners;
    
    switch ([self position]) {
        case ERPalettePanelPositionUp:
            corners = ERLowerRightCorner | ERLowerLeftCorner;
            break;
            
        case ERPalettePanelPositionDown:
            corners = ERUpperRightCorner | ERUpperLeftCorner;
            break;
            
        case ERPalettePanelPositionLeft:
            corners = ERUpperRightCorner | ERLowerRightCorner;
            break;
            
        case ERPalettePanelPositionRight:
            corners = ERLowerLeftCorner | ERUpperLeftCorner;
            break;
            
        default:
            corners = ERNoneCorner;
            break;
    }
    NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:[self barFrame] radius:5.0 corners:corners];
    
    NSGradient *backGradient;
    if (_highlight) {
        backGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:0.6] endingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:0.6]];
    }else{
        backGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:0.6] endingColor:[NSColor colorWithCalibratedWhite:0.6 alpha:0.6]];
    }

    [backGradient drawInBezierPath:bp angle:-90.*[self position]];

    [[NSColor colorWithDeviceWhite:0.8 alpha:0.9] set];
    [bp stroke];
    
    if (_highlight) {
        [[NSColor whiteColor] set];
        
        [[NSBezierPath bezierPathWithRoundedRect:_draggingPositionMarker xRadius:2.5 yRadius:2.5] fill];
    }
}

- (void)setBounds:(NSRect)aRect
{
    [super setBounds:aRect];
    [self updateBarFrame:NO];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self updateBarFrame:NO];
}
- (NSRect)barFrame
{
    return _barFrame;
}

- (void)setBarFrame:(NSRect)barFrame
{
    _barFrame = barFrame;
    [self setNeedsDisplay:YES];
}

- (NSRect)collapsedBarFrame
{
    NSRect bounds = [self bounds];
    NSRect frame = [self bounds];
    
    if ([self position] % 2 == 0) {
        frame.size.width *= 0.3;
        if ([self position] == ERPalettePanelPositionRight) {
            frame.origin.x += bounds.size.width - frame.size.width;
        }
    }else{
        frame.size.height *= 0.3;
        if ([self position] == ERPalettePanelPositionUp) {
            frame.origin.y += bounds.size.height - frame.size.height;
        }
    }
    
    return frame;
}

- (void)updateBarFrame:(BOOL)animate
{
    if ([_tabs count] > 0) {
        [self setBarFrameOpened:animate];
    }else{
        [self setBarFrameCollapsed:animate];
    }
    [self setNeedsDisplay:YES];
}

- (void)setBarFrameOpened:(BOOL)animate
{
    if (animate) {
        [[self animator] setBarFrame:[self bounds]];
    }else{
        [self setBarFrame:[self bounds]];
    }
}

- (void)setBarFrameCollapsed:(BOOL)animate
{
    if (animate) {
        [[self animator] setBarFrame:[self collapsedBarFrame]];
    }else{
        [self setBarFrame:[self collapsedBarFrame]];
    }
}

@synthesize position = _position;

- (NSArray *)tabs
{
    return _tabs;
}

@synthesize holder = _holder;

- (void)addPaletteWithContentView:(NSView *)contentView icon:(NSImage *)icon title:(NSString *)paletteTitle
{
    ERPalettePanel *palette = [[ERPalettePanel alloc] initWithContent:contentView position:[self position]];
    [palette setTitle:paletteTitle];
    [palette setIcon:icon];
    
    [palette setState:ERPaletteClosed animate:NO];
    
    [self addPalette:palette];
    [palette release];
}

- (void)addPalette:(ERPalettePanel *)palette
{
    CGFloat location;
    
    if ([_tabs count] > 0) {
        
        location = [[_tabs lastObject] locationInTabView]; // get the last element
        location += [ERPalettePanel tabWidth] + [ERPaletteTabView tabMargin];
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
    [palette invalidateShadow];
    
    [self updateTabsLocations];
    [self updateBarFrame:YES];
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
        
        [self updateBarFrame:YES];
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
        
        CGFloat minLoc = [current locationInTabView] + [ERPalettePanel tabWidth] + [ERPaletteTabView tabMargin];
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
    CGFloat maxY = [self frame].size.height - [ERPaletteTabView barExtremitiesMargins];
    CGFloat y;
    
    for (ERPalettePanel *palette in _tabs) {
        y = maxY - [palette locationInTabView] - [ERPalettePanel tabWidth];
        
        NSPoint frameOrigin = NSMakePoint(0, y);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
    }
}

- (void)_updateRightTabsLocations
{
    CGFloat maxY = [self frame].size.height - [ERPaletteTabView barExtremitiesMargins];
    CGFloat y;
    
    for (ERPalettePanel *palette in _tabs) {
        y = maxY - [palette locationInTabView] - [ERPalettePanel tabWidth];
        
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
        x = [palette locationInTabView] + [ERPaletteTabView barExtremitiesMargins];
        
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
        x = [palette locationInTabView] + [ERPaletteTabView barExtremitiesMargins];
        
        NSPoint frameOrigin = NSMakePoint(x, 0);
        frameOrigin = [self convertPoint:frameOrigin toView:nil];
        
        frameOrigin = [[self window] convertBaseToScreen:frameOrigin];
        [palette setTabOrigin:frameOrigin];
    }
}

- (int)tabPositionForMouseLocation:(NSPoint)location
{
    if ([self position] == ERPalettePanelPositionUp || [self position] == ERPalettePanelPositionDown) {
        CGFloat xAccumulator = [ERPalettePanel tabWidth];
        int i;
        for (i = 0; i < [_tabs count]; i++) {
            xAccumulator += [ERPalettePanel tabWidth];
            if (location.x < xAccumulator) {
                break;
            }else{
                xAccumulator += [ERPaletteTabView tabMargin];
            }
        }
        return i;
    }else{
        CGFloat yAccumulator = NSMaxY([self bounds]) - [ERPalettePanel tabWidth];
        int i;
        
        for (i = 0; i < [_tabs count]; i++) {
            yAccumulator -= [ERPalettePanel tabWidth];
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
        CGFloat x = location + [ERPaletteTabView barExtremitiesMargins];
        return NSInsetRect(NSMakeRect(x, 0, 5., [self frame].size.height),0,3.);
    }else{
        CGFloat y = location + [ERPaletteTabView barExtremitiesMargins];
        y = NSMaxY([self bounds]) - y;
        
        return NSInsetRect(NSMakeRect(0, y, [self frame].size.width, 5.),3.,0);
    }
}


#pragma mark Drag and Drop Palettes

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:ERPalettePboardType]]) {
        ERPalettePanel *palette = [sender draggingSource];
        
        if ([palette holder] == [self holder] || [palette holder] == nil) { // drag authorized only inside the same holder view
            _highlight = YES;

            if ([_tabs count] == 0) {
                [self setBarFrameOpened:YES];
            }

            NSPoint dropPoint = [self convertPoint:[sender draggingLocation] fromView:nil];
            CGFloat location;
            
            if ([self position] == ERPalettePanelPositionLeft || [self position] == ERPalettePanelPositionRight) {
                location = NSMaxY([self bounds]) - dropPoint.y;
            }else{
                location = dropPoint.x;
            }
            location -= [ERPaletteTabView barExtremitiesMargins];

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
                location = NSMaxY([self bounds]) - dropPoint.y;
            }else{
                location = dropPoint.x;
            }
            location -= [ERPaletteTabView barExtremitiesMargins];
            
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
    
    if ([_tabs count] == 0) {
        [self setBarFrameCollapsed:YES];
    }

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
                location = NSMaxY([self bounds]) - dropPoint.y;
            }else{
                location = dropPoint.x;
            }
            location -= [ERPaletteTabView barExtremitiesMargins];
            location -= [ERPalettePanel tabWidth]/2.;

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
                    location = NSMaxY([self bounds]) - dropPoint.y;
                }else{
                    location = dropPoint.x;
                }
                location -= [ERPaletteTabView barExtremitiesMargins];
                
                
                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPalettePanel tabWidth]/2.) {
                    location = paletteLocation;
                }else{
                    location = paletteLocation + [ERPalettePanel tabWidth] + [ERPaletteTabView tabMargin];
                }
                _draggingPositionMarker = [self markerForTabLocation:location];

                [self setNeedsDisplay:YES];
                
                return NSDragOperationMove;
            }else{
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
                    location = NSMaxY([self bounds]) - dropPoint.y;
                }else{
                    location = dropPoint.x;
                }
                location -= [ERPaletteTabView barExtremitiesMargins];
                
                
                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPalettePanel tabWidth]/2.) {
                    location = paletteLocation;
                }else{
                    location = paletteLocation + [ERPalettePanel tabWidth] + [ERPaletteTabView tabMargin];
                }
                _draggingPositionMarker = [self markerForTabLocation:location];

                [self setNeedsDisplay:YES];
                
                return NSDragOperationMove;
            }else{
                _highlight = NO;
                [self setNeedsDisplay:YES];

                return NSDragOperationMove;
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
                    location = NSMaxY([self bounds]) - dropPoint.y;
                }else{
                    location = dropPoint.x;
                }
                location -= [ERPaletteTabView barExtremitiesMargins];
                
                
                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPalettePanel tabWidth]/2.) {
                    location = paletteLocation;
                }else{
                    location = paletteLocation + [ERPalettePanel tabWidth] + [ERPaletteTabView tabMargin];
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
                    location = dropPoint.x + [ERPalettePanel tabWidth];
                }
                location -= [ERPalettePanel tabWidth];
                

                CGFloat paletteLocation = [palette locationInTabView];
                if (location < paletteLocation + [ERPalettePanel tabWidth]/2.) {
                    location = paletteLocation - [ERPalettePanel tabWidth] - [ERPaletteTabView tabMargin];
                }else{
                    location = paletteLocation + [ERPalettePanel tabWidth] + [ERPaletteTabView tabMargin];
                }

                if (oldTabView == self) { // we are just reordering tabs
                    [draggedPalette setLocationInTabView:location];
                    [self updateTabsLocations];
                }else{                    
                    [ERPaletteTabView moveTab:draggedPalette fromView:oldTabView toView:self atLocation:location];
                }

                return YES;
            }else{
                return YES;
            }
        }
        
    }
    return NO;
}

@end
