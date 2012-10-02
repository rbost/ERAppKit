//
//  ERDummyView.h
//  ERAppKit
//
//  Created by Raphael Bost on 25/09/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"

@interface ERDummyView : NSView
{
    
}
@property (assign) IBOutlet AppDelegate *delegate;
@property (readwrite,retain) NSColor *color;


- (IBAction)setWhite:(id)sender;
- (IBAction)setRed:(id)sender;
- (IBAction)setGreen:(id)sender;
- (IBAction)setYellow:(id)sender;
- (IBAction)setBlue:(id)sender;
- (IBAction)setOrange:(id)sender;
- (IBAction)setPurple:(id)sender;
- (IBAction)setGray:(id)sender;
- (IBAction)setBlack:(id)sender;
- (IBAction)setMagenta:(id)sender;
- (IBAction)setCyan:(id)sender;
- (IBAction)setDarkGray:(id)sender;
- (IBAction)setClear:(id)sender;

@end
