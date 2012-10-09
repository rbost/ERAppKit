//
//  ERTimer.h
//  ERAppKit
//
//  Created by Raphael Bost on 06/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The ERTimer class provides a timer which can be easily reset even if the timer time has not been elapsed
 */

@interface ERTimer : NSObject
@property (assign) NSTimeInterval interval;
@property (assign) id target;
@property (assign) SEL selector;
@property (retain) id argument;

/**
 Initialize a new timer with the specified time interval. When the time is elapsed, the timer will call [aTarget aSelector:anArgument]. If the selector has no argument, just pass nil for anArgument.
 \param aTimeInterval The time interval of the timer. In seconds.
 \param aTarget The object that will be called at the end of the timer
 \param aSelector The selector called on the target
 \param anArgument The argument passed to the selector
 */
- (id)initWithTimeInterval:(NSTimeInterval)aTimeInterval target:(id)aTarget selector:(SEL)aSelector argument:(id)anArgument;

/**
 Starts the timer
 */
- (void)start;

/**
 Stop the timer without triggering the selector
 */
- (void)stop;

/**
 Stops and restarts the timer. If the timer has not been started, this method just starts it.
 */
- (void)reset;

@end
