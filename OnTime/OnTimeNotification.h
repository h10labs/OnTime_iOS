//
//  OnTimeNotification.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 10/12/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kStartId;
extern NSString * const kDestinationId;
extern NSString * const kSnoozableKey;
extern NSString * const kTravelModeKey;

@interface OnTimeNotification : NSObject

// default initializer
- (id)initWithNotificationData:(NSDictionary *)notificationData;

- (void)scheduleNotification:(NSInteger)notificationIndex;

@end