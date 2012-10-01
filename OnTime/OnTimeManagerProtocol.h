//
//  OnTimeManagerProtocol.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Station;

@protocol OnTimeManagerProtocol <NSObject>

+ (id<OnTimeManagerProtocol>)sharedStore;
- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion:(void (^)(NSArray *stations, NSError *err))block;

-  (NSArray *) nearbyStations:(NSInteger)numStations;

- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSDictionary *notificationData, NSError *err))block;
- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex;
- (Station *)getSelecedStation:(NSInteger)groupIndex;

@property (nonatomic, strong)NSArray *nearbyStations;
@end
