//
//  BartStationStore.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "BartStationStore.h"
#import "OnTimeConnection.h"

NSString * const bartStationUrlTemplate = @"http://ontime.nodejitsu.com/bart/locate/?lat=%f&long=%f";
NSString * const bartNotificationUrl = @"";

@implementation BartStationStore

+ (BartStationStore *)sharedStore {
    static BartStationStore *stationStore = nil;
    if (!stationStore){
        stationStore = [[BartStationStore alloc] init];
    }
    return stationStore;
}

- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion: (void (^)(NSArray *stations, NSError *err))block {
    CLLocationCoordinate2D coords = [currentLocation coordinate];
    NSString *urlString = [NSString stringWithFormat:bartStationUrlTemplate,
                           coords.latitude, coords.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    OnTimeConnection *connection = [[OnTimeConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection start];
    NSLog(@"get location for %@", currentLocation);
}

- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSDictionary *notificationData, NSError *err))block {
    NSURL *url = [NSURL URLWithString:bartNotificationUrl];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    OnTimeConnection *connection = [[OnTimeConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection start];
    NSLog(@"request notification for %@", requestData);
}
@end
