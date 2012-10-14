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
    @"Leave at %@ to catch %@ at %@; %@ there will take %d minute(s).";
static NSString * const reminderMessage =
    @"Leave now to catch %@ at %@; %@ there will take %d minute(s).";

static NSString * const arrivalTimeKey = @"arrivalTimeInMinutes";
static NSString * const destinationKey = @"destination";

// date format is specified to be "12:14 AM"
static NSString * const dateFormatTempalte = @"hh:mm a";

// notification data dictionary keys
static NSString * const bufferTimeKey = @"bufferTime";
static NSString * const durationKey = @"duration";
static NSString * const modeKey = @"mode";
static NSString * const startKey = @"start";
static NSString * const estimateKey = @"arrivalEstimates";

@interface OnTimeNotification () {
    NSArray *notificationEstimates;
    NSNumber *durationTime;
    NSNumber *bufferTime;
    NSString *mode;
    NSString *startStation;
}
@end

@implementation OnTimeNotification

- (id)initWithNotificationData:(NSDictionary *)notificationData {
    self = [super init];
    if (self) {
        bufferTime = [notificationData objectForKey:bufferTimeKey];
        durationTime = [notificationData objectForKey:durationKey];
        mode = [notificationData objectForKey:modeKey];
        startStation = [notificationData objectForKey:startKey];
        notificationEstimates = [notificationData objectForKey:estimateKey];
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

    // create local notification to notify now
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];

    // setting up date formatter
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateFormatTempalte
                                                           options:0
                                                            locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    NSString *scheduledTimeString = [formatter stringFromDate:scheduledTime];

    [notification setFireDate:now];
    [notification setAlertAction:notificationTitle];
    [notification setAlertBody:[NSString stringWithFormat:notificationMessage,
                                scheduledTimeString,
                                destination,
                                startStation,
                                mode,
                                [durationTime intValue] / 60]];
    [notification setHasAction:NO];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    // create local notification to notify at the appropriate time
    notification = [[UILocalNotification alloc] init];
    [notification setFireDate:scheduledTime];
    [notification setAlertAction:notificationTitle];
    [notification setAlertBody:[NSString stringWithFormat:reminderMessage,
                                destination,
                                startStation,
                                mode,
                                [durationTime intValue] / 60]];
    [notification setHasAction:NO];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
@end
