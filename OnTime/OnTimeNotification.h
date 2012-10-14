//
//  OnTimeNotification.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 10/12/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnTimeNotification : NSObject

// default initializer
- (id)initWithNotificationData:(NSDictionary *)notificationData;

- (void)scheduleNotification:(NSInteger)notificationIndex;

@end
