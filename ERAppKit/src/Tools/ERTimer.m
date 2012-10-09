//
//  ERTimer.m
//  ERAppKit
//
//  Created by Raphael Bost on 06/10/12.
//  Copyright (c) 2012 Evan Altman, Raphael Bost. All rights reserved.
//

#import "ERTimer.h"

@interface ERTimer ()
- (void)_startNewRequest;
- (void)_resetPreviousRequests;

- (void)_requestCallBack:(id)arg;
@end

@implementation ERTimer

- (id)initWithTimeInterval:(NSTimeInterval)aTimeInterval target:(id)aTarget selector:(SEL)aSelector argument:(id)anArgument
{
    self = [super init];
    
    [self setInterval:aTimeInterval];
    [self setTarget:aTarget];
    [self setSelector:aSelector];
    [self setArgument:anArgument];
    
    return self;
}

- (void)dealloc
{
    [self _resetPreviousRequests];
    [self setArgument:nil];
    
    [super dealloc];
}

@synthesize interval, target, selector, argument;

- (void)start
{
    [self _startNewRequest];
}

- (void)stop
{
    [self _resetPreviousRequests];    
}

- (void)reset
{
    [self _resetPreviousRequests];
    [self _startNewRequest];
}

- (void)_startNewRequest
{
    [self performSelector:@selector(_requestCallBack:) withObject:[self argument] afterDelay:[self interval]];
}

- (void)_resetPreviousRequests
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; 
}

- (void)_requestCallBack:(id)arg
{
    [target performSelector:selector withObject:arg];
}
@end
