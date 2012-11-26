//
//  OnTimeNotification.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 10/12/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeNotification.h"

static NSString * const notificationTitle = @"OnTime!";
static NSString * const snoozeLabel = @"Snooze";
static NSString * const notificationMessage =
    @"Leave at %@ to catch %@ at %@ arriving at %@; %@ there will take %d minute(s).";
static NSString * const reminderMessage =
    @"Leave now to catch %@ at %@ arriving at %@; %@ there will take %d minute(s).";

static NSString * const arrivalTimeKey = @"arrivalTimeInMinutes";
static NSString * const destinationKey = @"destination";

// date format is specified to be "12:14 AM"
static NSString * const dateFormatTempalte = @"hh:mm a";

// notification data dictionary keys
static NSString * const bufferTimeKey = @"bufferTime";
static NSString * const durationKey = @"duration";
static NSString * const modeKey = @"mode";
static NSString * const startInfoKey = @"startInfo";
static NSString * const destinationInfoKey = @"destinationInfo";
static NSString * const estimateKey = @"arrivalEstimates";

// notification data sub dictionary keys
static NSString * const stationNameKey = @"name";
static NSString * const stationIdKey = @"id";

// user info dictionary key
NSString * const kStartId = @"startId";
NSString * const kDestinationId = @"destinationId";
NSString * const kSnoozableKey = @"isSnoozable";

// dictionary for the different modes
static NSDictionary *modeDictionary = nil;

@interface OnTimeNotification () {
    NSArray *notificationEstimates;
    NSNumber *durationTime;
    NSNumber *bufferTime;
    NSString *mode;
    NSDictionary *startStationInfo;
    NSDictionary *destinationStationInfo;
}
@end

@implementation OnTimeNotification

- (id)initWithNotificationData:(NSDictionary *)notificationData {
    self = [super init];
    if (self) {
        if (!modeDictionary) {
            modeDictionary = @{@0:@"walking", @1:@"biking", @2:@"driving"};
        }

        bufferTime = notificationData[bufferTimeKey];
        durationTime = notificationData[durationKey];
        startStationInfo = notificationData[startInfoKey];
        destinationStationInfo = notificationData[destinationInfoKey];
        notificationEstimates = notificationData[estimateKey];

        mode = modeDictionary[notificationData[modeKey]];
        if (!mode) {
            // Log this case since it's unexpected.
            NSLog(@"Unexpected mode was returned by server: %@",
                  notificationData[modeKey]);
            // Set the default mode string.
            mode = @"getting";
        }
    }
    return self;
}

- (id)init {
    [NSException raise:@"Default init failed"
                format:@"Reason: init is not supported by %@", [self class]];
    return nil;
}

- (void)scheduleNotification:(NSInteger)notificationIndex {
    // Retrieve the specified notification data.
    NSDictionary *notificationData = notificationEstimates[notificationIndex];

    NSString *trainDestinationName = notificationData[destinationKey];

    // setting up date formatter
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [NSLocale currentLocale];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateFormatTempalte
                                                               options:0
                                                                locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
    }

    // Convert the arrival time into a string.
    NSInteger arrivalTimeInSeconds =
        [[notificationData objectForKey:arrivalTimeKey] intValue] * 60;
    NSDate *arrivalTime = [NSDate dateWithTimeIntervalSinceNow:arrivalTimeInSeconds];
    NSString *arrivalTimeString = [formatter stringFromDate:arrivalTime];

    // Convert the scheduled time for departure to the station into a string.
    NSInteger scheduledTimeInSeconds = arrivalTimeInSeconds - [durationTime intValue] -
        [bufferTime intValue];
    NSDate *scheduledTime = [NSDate dateWithTimeIntervalSinceNow:scheduledTimeInSeconds];
    NSString *scheduledTimeString = [formatter stringFromDate:scheduledTime];

    // Create the alert to inform users what time they will have to leave for
    // the station.
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:notificationTitle
                                                 message:[NSString stringWithFormat:notificationMessage,
                                                          scheduledTimeString,
                                                          trainDestinationName,
                                                          startStationInfo[stationNameKey],
                                                          arrivalTimeString,
                                                          mode,
                                                          [durationTime intValue] / 60]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];

    // Create local notification to notify at the appropriate time.
    // First create user info dictionary
    NSDictionary *userInfo = @{kStartId: startStationInfo[stationIdKey],
                               kDestinationId: destinationStationInfo[stationIdKey],
                               kSnoozableKey: @YES};
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setFireDate:scheduledTime];
    [notification setAlertAction:snoozeLabel];
    [notification setAlertBody:[NSString stringWithFormat:reminderMessage,
                                trainDestinationName,
                                startStationInfo[stationNameKey],
                                arrivalTimeString,
                                mode,
                                [durationTime intValue] / 60]];
    [notification setHasAction:YES];
    [notification setUserInfo:userInfo];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
