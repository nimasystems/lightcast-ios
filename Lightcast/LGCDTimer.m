//
//  LGCDTimer.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 07.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LGCDTimer.h"

// original source: http://www.fieryrobot.com/blog/2010/07/10/a-watchdog-timer-in-gcd/

@interface LGCDTimer()

@property (nonatomic, assign) BOOL isRunning;

@end

@implementation LGCDTimer {
    dispatch_source_t _timer;
}

#pragma mark - Initialization / Finalization

- (id)initWithTimeout:(NSTimeInterval)timeout
{
    self = [super init];
    if (self)
    {
        self.interval = timeout;
    }
    return self;
}

- (id)init
{
    return [self initWithTimeout:1.0];
}

- (void)dealloc
{
    self.timerDelegate = nil;
    [self stop];
}


#pragma mark - Timer methods

- (dispatch_source_t)dispatchTimerInstance:(NSTimeInterval)interval queue:(dispatch_queue_t)queue block:(dispatch_block_t)block {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    
    return timer;
}

- (void)invalidate {
    [self stop];
}

- (void)stop
{
    if (self.isRunning) {
        if (_timer) {
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
        self.isRunning = NO;
    }
}

- (void)start
{
    if (self.isRunning || !self.interval) {
        return;
    }
    
    self.isRunning = YES;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    _timer = [self dispatchTimerInstance:self.interval queue:queue block:^{
        if (self.timerDelegate && [self.timerDelegate respondsToSelector:@selector(gcdTimerFired:)]) {
            [self.timerDelegate gcdTimerFired:self];
        }
    }];
}

@end
