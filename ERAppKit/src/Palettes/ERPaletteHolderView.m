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

@interface ERPaletteHolderView ()
@property (readonly) ERPaletteTabView *leftTabs;
@property (readonly) ERPaletteTabView *rightTabs;
@property (readonly) ERPaletteTabView *upTabs;
@property (readonly) ERPaletteTabView *downTabs;
@end

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

        _leftTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionLeft];
        _rightTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionRight];
        _upTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionUp];
        _downTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionDown];
        
        [self setAutoresizesSubviews:YES];
        
        [self addSubview:_leftTabs positioned:NSWindowAbove relativeTo:nil]; [_leftTabs release]; [_leftTabs setAutoresizingMask:(NSViewHeightSizable|NSViewMaxXMargin)];
        [self addSubview:_rightTabs positioned:NSWindowAbove relativeTo:nil]; [_rightTabs release]; [_rightTabs setAutoresizingMask:(NSViewHeightSizable|NSViewMinXMargin)];
        [self addSubview:_upTabs positioned:NSWindowAbove relativeTo:nil]; [_upTabs release]; [_upTabs setAutoresizingMask:(NSViewWidthSizable|NSViewMinYMargin)];
        [self addSubview:_downTabs positioned:NSWindowAbove relativeTo:nil]; [_downTabs release]; [_downTabs setAutoresizingMask:(NSViewWidthSizable|NSViewMaxYMargin)];
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

    [super dealloc];
}

NSComparisonResult viewSort(id v1, id v2, void* context)
{
    ERPaletteHolderView *sortedView = context;
    if (v1 == [sortedView leftTabs] || v1 == [sortedView rightTabs] || v1 == [sortedView upTabs] || v1 == [sortedView downTabs]) {
        return NSOrderedDescending;
    }else if(v2 == [sortedView leftTabs] || v2 == [sortedView rightTabs] || v2 == [sortedView upTabs] || v2 == [sortedView downTabs]) {
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

- (void)addPaletteWithContentView:(NSView *)contentView icon:(NSImage *)icon title:(NSString *)paletteTitle atPosition:(ERPalettePanelPosition)pos
{
    switch (pos) {
        case ERPalettePanelPositionRight:
            [_rightTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        case ERPalettePanelPositionLeft:
            [_leftTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        case ERPalettePanelPositionUp:
            [_upTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        case ERPalettePanelPositionDown:
            [_downTabs addPaletteWithContentView:contentView icon:icon title:paletteTitle];
            break;
            
        default:
            break;
    }
    
}

- (void)collapsePaletteIntersectingRect:(NSRect)frame
{
    for (ERPalettePanel *p in [_leftTabs tabs]) {
        if (NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }
    for (ERPalettePanel *p in [_rightTabs tabs]) {
        if (NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }
    for (ERPalettePanel *p in [_upTabs tabs]) {
        if (NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }
    for (ERPalettePanel *p in [_downTabs tabs]) {
        if (NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }

}

- (void)collapsePaletteIntersectingRect:(NSRect)frame except:(NSWindow *)window
{
    for (ERPalettePanel *p in [_leftTabs tabs]) {
        if (p != window && NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }
    for (ERPalettePanel *p in [_rightTabs tabs]) {
        if (p != window && NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }
    for (ERPalettePanel *p in [_upTabs tabs]) {
        if (p != window && NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }
    for (ERPalettePanel *p in [_downTabs tabs]) {
        if (p != window && NSIntersectsRect([p frame], frame)) {
            [p setState:ERPaletteClosed animate:YES];
        }
    }
    
}

- (BOOL)isFrameEmptyFromPalettes:(NSRect)frame except:(NSWindow *)window
{
    for (ERPalettePanel *p in [_leftTabs tabs]) {
        if (p != window && NSIntersectsRect([p contentScreenFrame], frame)) {
//            NSLog(NSStringFromRect([p contentFrame]));
//            NSLog(NSStringFromRect(frame));
            
            return NO;
        }
    }
    for (ERPalettePanel *p in [_rightTabs tabs]) {
        if (p != window && NSIntersectsRect([p contentScreenFrame], frame)) {
            return NO;
        }
    }
    for (ERPalettePanel *p in [_upTabs tabs]) {
        if (p != window && NSIntersectsRect([p contentScreenFrame], frame)) {
            return NO;
        }
    }
    for (ERPalettePanel *p in [_downTabs tabs]) {
        if (p != window && NSIntersectsRect([p contentScreenFrame], frame)) {
            return NO;
        }
    }
    
    return YES;
}

@synthesize leftTabs = _leftTabs, rightTabs = _rightTabs, upTabs = _upTabs, downTabs = _downTabs;

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
