//
//  ERPalettePanel.m
//  ERAppKit
//
//  Created by Raphael Bost on 07/11/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERPalettePanel.h"

#import <ERAppKit/ERPaletteContentView.h>
#import <ERAppKit/NSWindow+ThreadedResize.h>


NSString *ERPaletteDidCloseNotification = @"Palette did close";
NSString *ERPaletteDidOpenNotification = @"Palette did open";
NSString *ERPaletteNewFrameKey = @"New palette frame";
NSString *ERPalettePboardType = @"Palette Pasteboard Type";

@implementation ERPalettePanel
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];

    ERPaletteContentView *contentView = [[ERPaletteContentView alloc] initWithFrame:NSMakeRect(0, 0, contentRect.size.width, contentRect.size.height)];
    [self setContentView:contentView];
    _state = ERPaletteOpenedInside;
    [self setBecomesKeyOnlyIfNeeded:YES];
        
    return self;
}

- (id)initWithContent:(NSView *)content position:(ERPalettePanelPosition)pos
{
    _palettePosition = pos;
    NSRect contentRect;
    contentRect.size = [content frame].size;
    contentRect.origin = NSMakePoint(400, 400);
    
    if ([self palettePosition] == ERPalettePanelPositionDown || [self palettePosition] == ERPalettePanelPositionUp) {
        contentRect.size.height += [ERPaletteContentView paletteTitleSize];
    }else{
        contentRect.size.width += [ERPaletteContentView paletteTitleSize];
    }

    self = [self initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];

    [self setContent:content];
    
    [self updateAutoresizingMask];
    
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (ERPalettePanelPosition)palettePosition
{
    return _palettePosition;
}

- (void)setPalettePosition:(ERPalettePanelPosition)palettePosition
{
    if (palettePosition == _palettePosition) {
        return;
    }
    
    _palettePosition = palettePosition;
    // update the content autosizing mask with respect to the new position of the palette
    [self updateAutoresizingMask];
}

- (void)updateAutoresizingMask
{
    NSUInteger mask;
    
    switch ([self palettePosition]) {
        case ERPalettePanelPositionUp:
            mask = NSViewMaxYMargin;
            break;
            
        case ERPalettePanelPositionDown:
            mask = NSViewMinYMargin;
            break;
            
        case ERPalettePanelPositionLeft:
            mask = NSViewMinXMargin;
            break;
            
        case ERPalettePanelPositionRight:
            mask = NSViewMaxXMargin;
            break;
            
        default:
            break;
    }
    
    [[self content] setAutoresizingMask:mask];
}

- (ERPaletteState)state
{
    return _palettePosition;
}

- (void)setState:(ERPaletteState)state
{
    [self setState:state animate:NO];
}
- (void)setState:(ERPaletteState)state animate:(BOOL)animate
{
    if (state == _state) {
        return;
    }
    
    if (state == ERPaletteClosed) {
        NSRect newFrame;
        NSRect headerRect = [(ERPaletteContentView *)[self contentView] headerRect];
        
        newFrame.size = headerRect.size;
        newFrame.origin = [[self contentView] convertPoint:headerRect.origin toView:nil]; // coordinates in the window base
        
        if (_state == ERPaletteOpenedInside) {
            if ([self palettePosition] == ERPalettePanelPositionDown) {
                newFrame.origin = NSZeroPoint;
            }else if([self palettePosition] == ERPalettePanelPositionUp) {
                newFrame.origin = NSMakePoint(0, [self frame].size.height - [ERPaletteContentView paletteTitleSize]);
            }else if([self palettePosition] == ERPalettePanelPositionLeft) {
                newFrame.origin = NSZeroPoint;
            }else if([self palettePosition] == ERPalettePanelPositionRight) {
                newFrame.origin = NSMakePoint([self frame].size.width - [ERPaletteContentView paletteTitleSize],0);
            }
            
            newFrame = [self convertRectToScreen:newFrame];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidCloseNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:newFrame] forKey:ERPaletteNewFrameKey]];
            
            if (animate) {
                [[self animator] setFrame:newFrame display:YES];
            }else{
                [self setFrame:newFrame display:YES];
            }

        }else if (_state == ERPaletteOpenedOutside){
            if ([self palettePosition] == ERPalettePanelPositionDown) {
                newFrame.origin = NSMakePoint(0, [self frame].size.height - [ERPaletteContentView paletteTitleSize]);
            }else if([self palettePosition] == ERPalettePanelPositionUp) {
                newFrame.origin = NSZeroPoint;
            }else if([self palettePosition] == ERPalettePanelPositionLeft) {
                newFrame.origin = NSMakePoint([self frame].size.width - [ERPaletteContentView paletteTitleSize],0);
            }else if([self palettePosition] == ERPalettePanelPositionRight) {
                newFrame.origin = NSZeroPoint;
            }
            
            newFrame = [self convertRectToScreen:newFrame];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidCloseNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:newFrame] forKey:ERPaletteNewFrameKey]];
            
            if (animate) {
                [[self animator] setFrame:newFrame display:YES];
            }else{
                [self setFrame:newFrame display:YES];
            }
        }
    }else if (state == ERPaletteOpenedInside) {
        NSRect newFrame;
        
        newFrame.size = [self paletteSize];
        newFrame.origin = [self frame].origin;
        
        if ([self palettePosition] == ERPalettePanelPositionDown) {
        }else if([self palettePosition] == ERPalettePanelPositionUp) {
            newFrame.origin.y -= newFrame.size.height - [ERPaletteContentView paletteTitleSize];
        }else if ([self palettePosition] == ERPalettePanelPositionLeft) {
        }else if ([self palettePosition] == ERPalettePanelPositionRight) {
            newFrame.origin.x -= newFrame.size.width - [ERPaletteContentView paletteTitleSize];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidOpenNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:newFrame] forKey:ERPaletteNewFrameKey]];

        if (animate) {
            [[self animator] setFrame:newFrame display:YES];
        }else{
            [self setFrame:newFrame display:YES];
        }
    }else if (state == ERPaletteOpenedOutside) {
        NSRect newFrame;
        
        newFrame.size = [self paletteSize];
        newFrame.origin = [self frame].origin;
        
        if ([self palettePosition] == ERPalettePanelPositionDown) {
            newFrame.origin.y -= newFrame.size.height - [ERPaletteContentView paletteTitleSize];
        }else if([self palettePosition] == ERPalettePanelPositionUp) {
        }else if ([self palettePosition] == ERPalettePanelPositionLeft) {
            newFrame.origin.x -= newFrame.size.width - [ERPaletteContentView paletteTitleSize];
        }else if ([self palettePosition] == ERPalettePanelPositionRight) {
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ERPaletteDidOpenNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:newFrame] forKey:ERPaletteNewFrameKey]];
        
        if (animate) {
            [[self animator] setFrame:newFrame display:YES];
        }else{
            [self setFrame:newFrame display:YES];
        }
    }
    
    _state = state;
}


- (IBAction)toggleCollapse:(id)sender
{
    if (_state != ERPaletteClosed) {
        [self setState:ERPaletteClosed animate:YES];
    }else{
        [self setState:ERPaletteOpenedOutside animate:YES];
    }    
}

- (NSView *)content
{
    return _content;
}

- (void)setContent:(NSView *)newContent
{
    [newContent retain];
    [_content removeFromSuperview];
    
    _content = newContent;
    [[self contentView] addSubview:_content];
    NSPoint frameOrigin = NSZeroPoint;
    
    if ([self palettePosition] == ERPalettePanelPositionUp) {
        frameOrigin.y = [ERPaletteContentView paletteTitleSize];
    }else if ([self palettePosition] == ERPalettePanelPositionRight) {
        frameOrigin.x = [ERPaletteContentView paletteTitleSize];
    }
    
    [_content setFrameOrigin:frameOrigin];
}

- (NSSize)paletteSize
{
    NSSize size = [[self content] frame].size;
    
    if ([self palettePosition] == ERPalettePanelPositionDown || [self palettePosition] == ERPalettePanelPositionUp) {
        size.height += [ERPaletteContentView paletteTitleSize];
    }else{
        size.width += [ERPaletteContentView paletteTitleSize];
    }
    
    return size;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    switch(context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationNone;
            break;
            
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationMove;
            break;
    }
}
@end
