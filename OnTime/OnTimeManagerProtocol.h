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

// retrieves the single instance of the object that implements this
// protocol
+ (id<OnTimeManagerProtocol>)sharedStore;

// given the current location, retrieve nearby stations.
// provide the completion block to perform action after the stations are
// retrieved.
- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion:(void (^)(NSArray *stations, NSError *err))block;

// retrieve specified number of nearby stations.
// note that if numStations is greater than the number of possible nearby
// stations, it will return as many nearby station there are.
- (NSArray *)nearbyStations:(NSInteger)numStations;

// submit the notification request to the server.
// provide the completion block to perform action after the notification is
// submited and received a response.
- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSDictionary *notificationData, NSError *err))block;

// make the station selection of the given group (e.g. source or destination)
- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex;

// get the selected station of the given group.
- (Station *)getSelecedStation:(NSInteger)groupIndex;


// reset currently selected stations to be unselected
- (void)resetCurrentSelectedStations;

@property (nonatomic, strong)NSArray *nearbyStations;
@end
