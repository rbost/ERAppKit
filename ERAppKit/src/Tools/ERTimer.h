//
//  ERTimer.h
//  ERAppKit
//
//  Created by Raphael Bost on 06/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERTimer : NSObject
@property (assign) NSTimeInterval interval;
@property (assign) id target;
@property (assign) SEL selector;
@property (retain) id argument;

- (id)initWithTimeInterval:(NSTimeInterval)aTimeInterval target:(id)aTarget selector:(SEL)aSelector argument:(id)anArgument;
- (void)start;
- (void)stop;
- (void)reset;

@end
