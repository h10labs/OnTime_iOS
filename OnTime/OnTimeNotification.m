//
//  OnTimeNotification.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 10/12/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeNotification.h"

static NSString * const notificationTitle = @"OnTime!";
static NSString * const notificationMessage =
    @"Leave at %@ to catch %@; it will take %d minute(s) to get there.";
static NSString * const reminderMessage =
    @"Leave now to catch %@; it will take %d minute(s) to get there.";

static NSString * const arrivalTimeKey = @"arrivalTimeInMinutes";
static NSString * const destinationKey = @"destination";

@interface OnTimeNotification () {
    NSArray *notificationEstimates;
    NSNumber *durationTime;
    NSNumber *bufferTime;
}
@end

@implementation OnTimeNotification

- (id)initWithNotificationData:(NSArray *)estimatesForNotification
                  withDuration:(NSNumber *)duration
                    withBuffer:(NSNumber *)buffer {
    self = [super init];
    if (self) {
        notificationEstimates = estimatesForNotification;
        durationTime = duration;
        bufferTime = buffer;
    }
    return self;
}

- (id)init {
    [NSException raise:@"Default init failed"
                format:@"Reason: init is not supported by %@", [self class]];
    return nil;
}

- (void)scheduleNotification:(NSInteger)notificationIndex {
    NSDictionary *notificationData =
        [notificationEstimates objectAtIndex:notificationIndex];

    NSString *destination = [notificationData objectForKey:destinationKey];
    NSInteger arrivalTimeInSeconds =
        [[notificationData objectForKey:arrivalTimeKey] intValue] * 60;
    NSInteger scheduledTimeInSeconds = arrivalTimeInSeconds -
    [durationTime intValue] - [bufferTime intValue];
    NSDate *scheduledTime = [NSDate dateWithTimeIntervalSinceNow:scheduledTimeInSeconds];


    // TODO: get the source station name as well as the mode to get to the station.
    
    // create local notification to notify now
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    [notification setFireDate:now];
    [notification setAlertAction:notificationTitle];
    [notification setAlertBody:[NSString stringWithFormat:notificationMessage,
                                scheduledTime, destination, [durationTime intValue] / 60]];
    [notification setHasAction:NO];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    // create local notification to notify at the appropriate time
    notification = [[UILocalNotification alloc] init];
    [notification setFireDate:scheduledTime];
    [notification setAlertAction:notificationTitle];
    [notification setAlertBody:[NSString stringWithFormat:reminderMessage,
                                destination, [durationTime intValue] / 60]];
    [notification setHasAction:NO];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
@end
