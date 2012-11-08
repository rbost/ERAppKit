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
//        _leftPalettes = [[NSMutableArray alloc] init];
//        _rightPalettes = [[NSMutableArray alloc] init];
//        _upPalettes = [[NSMutableArray alloc] init];
//        _downPalettes = [[NSMutableArray alloc] init];
        
        
        _leftTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionLeft];
        _rightTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionRight];
        _upTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionUp];
        _downTabs = [[ERPaletteTabView alloc] initWithHolder:self position:ERPalettePanelPositionDown];
        
        [self addSubview:_leftTabs]; [_leftTabs release];
        [self addSubview:_rightTabs]; [_rightTabs release];
        [self addSubview:_upTabs]; [_upTabs release];
        [self addSubview:_downTabs]; [_downTabs release];
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

//    [_leftPalettes release];
//    [_rightPalettes release];
//    [_upPalettes release];
//    [_downPalettes release];
    
    [super dealloc];
}

- (void)addPaletteWithContentView:(NSView *)contentView withTitle:(NSString *)paletteTitle atPosition:(ERPalettePanelPosition)pos
{
    switch (pos) {
        case ERPalettePanelPositionRight:
            [_rightTabs addPaletteWithContentView:contentView withTitle:paletteTitle];
            break;
            
        case ERPalettePanelPositionLeft:
            [_leftTabs addPaletteWithContentView:contentView withTitle:paletteTitle];
            break;
            
        case ERPalettePanelPositionUp:
            [_upTabs addPaletteWithContentView:contentView withTitle:paletteTitle];
            break;
            
        case ERPalettePanelPositionDown:
            [_downTabs addPaletteWithContentView:contentView withTitle:paletteTitle];
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

#pragma mark Notifications

- (void)paletteDidClose:(NSNotification *)note
{
    
}

- (void)paletteDidOpen:(NSNotification *)note
{
    NSRect newFrame = [(NSValue *)[[note userInfo] objectForKey:ERPaletteNewFrameKey] rectValue];
    [self collapsePaletteIntersectingRect:newFrame];
}


@end
