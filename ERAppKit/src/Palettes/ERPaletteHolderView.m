//
//  ERPaletteHolderView.m
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPaletteHolderView.h"

#import <ERAppKit/ERPaletteContentView.h>
#import <ERAppKit/ERPaletteTabView.h>

static CGFloat __tabMargin = 5.;

@implementation ERPaletteHolderView
+ (CGFloat)tabMargin
{
    return __tabMargin;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.

        _tabViews = [[NSMutableArray alloc] init];
        [self setAutoresizesSubviews:YES];
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_tabViews release];
    
    [super dealloc];
}

- (NSArray *)tabViews
{
    return _tabViews;
}

NSComparisonResult viewSort(id v1, id v2, void* context)
{
    ERPaletteHolderView *sortedView = context;
    if ([[sortedView tabViews] containsObject:v1]) {
        return NSOrderedDescending;
    }else if ([[sortedView tabViews] containsObject:v2]) {
        return NSOrderedAscending;
    }else{
        return NSOrderedSame;
    }

}

- (void)addSubview:(NSView *)aView
{
    [super addSubview:aView];
    
    // force the tab view to be over the other subviews
    [self sortSubviewsUsingFunction:viewSort context:self];
}

- (void)addTabView:(ERPaletteTabView *)view
{
    [_tabViews addObject:view];
    [self addSubview:view];
    
    switch ([view position]) {
        case ERPalettePanelPositionLeft:
            [view setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
            break;

        case ERPalettePanelPositionRight:
            [view setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
            break;
            
        case ERPalettePanelPositionUp:
            [view setAutoresizingMask:NSViewMinYMargin];
            break;
            
        case ERPalettePanelPositionDown:
            [view setAutoresizingMask:NSViewMaxYMargin];
            break;
            
        default:
            break;
    }
    
    [self sortSubviewsUsingFunction:viewSort context:self];
}

- (ERPaletteTabView *)addTabViewWithPosition:(ERPalettePanelPosition)pos
{
    ERPaletteTabView *tabView = [[ERPaletteTabView alloc] initWithHolder:self position:pos];
    
    [self addTabView:tabView];
    [tabView release];
    
    return tabView;
}

- (ERPaletteTabView *)addTabViewWithSize:(CGFloat)tabSize location:(CGFloat)location position:(ERPalettePanelPosition)pos;
{
    NSRect frame;
    CGFloat barThickness = [ERPaletteTabView barThickness];

    switch (pos) {
        case ERPalettePanelPositionLeft:
            frame = NSMakeRect(0, location, barThickness, tabSize);
            break;
            
        case ERPalettePanelPositionDown:
            frame = NSMakeRect(location, 0, tabSize, barThickness);
            break;
            
        case ERPalettePanelPositionRight:
            frame = NSMakeRect([self frame].size.width - barThickness, location, barThickness, tabSize);
            break;
            
        case ERPalettePanelPositionUp:
            frame = NSMakeRect(location, [self frame].size.height - barThickness, tabSize, barThickness);
            break;
            
        default:
            frame = NSZeroRect;
            break;
    }

    ERPaletteTabView *tabView = [[ERPaletteTabView alloc] initWithHolder:self frame:frame position:pos];
    
    [self addTabView:tabView];
    [tabView release];

    return tabView;
}

- (void)removeTabView:(ERPaletteTabView *)view
{
    if ([view superview] == self) {
        [view removeFromSuperview];
        [_tabViews removeObject:view];
    }
}

- (void)collapsePaletteIntersectingRect:(NSRect)frame
{
    for (ERPaletteTabView *tabView in _tabViews) {
        for (ERPalettePanel *p in [tabView tabs]) {
            if (NSIntersectsRect([p frame], frame)) {
                [p setState:ERPaletteClosed animate:YES];
            }
        }
    }
}

- (void)collapsePaletteIntersectingRect:(NSRect)frame except:(NSWindow *)window
{
    for (ERPaletteTabView *tabView in _tabViews) {
        for (ERPalettePanel *p in [tabView tabs]) {
            if (p != window && NSIntersectsRect([p frame], frame)) {
                [p setState:ERPaletteClosed animate:YES];
            }
        }
    }    
}

- (BOOL)isFrameEmptyFromPalettes:(NSRect)frame except:(NSWindow *)window
{
    for (ERPaletteTabView *tabView in _tabViews) {
        for (ERPalettePanel *p in [tabView tabs]) {
            if (p != window && NSIntersectsRect([p contentScreenFrame], frame)) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark Notifications

- (void)paletteDidClose:(NSNotification *)note
{
    
}

- (void)paletteDidOpen:(NSNotification *)note
{
    NSRect newFrame ;

    newFrame = [(NSValue *)[[note userInfo] objectForKey:ERPaletteNewFrameKey] rectValue];
    [self collapsePaletteIntersectingRect:newFrame except:[note object]];
}

@end
