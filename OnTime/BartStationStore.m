//
//  BartStationStore.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "BartStationStore.h"
#import "OnTimeConnection.h"
#import "BartStation.h"

const NSInteger limitedStationNumber = 3;

static NSString * const bartStationUrlTemplate = @"http://ontime.nodejitsu.com/bart/locate/?lat=%f&long=%f";
static NSString * const bartNotificationUrl = @"http://ontime.nodejitsu.com/bart/notify";

// keys for stations json objects
static NSString * const successKey = @"success";
static NSString * const stationDictKey = @"stations";
static NSString * const stationIdKey = @"id";
static NSString * const stationNameKey = @"name";
static NSString * const stationAddressKey = @"address";
static NSString * const stationLocationKey = @"location";

// keys for notification request
NSString * const distanceModeKey = @"mode";
NSString * const sourceStationKey = @"start";
NSString * const destinationStationKey = @"end";
NSString * const latitudeKey = @"lat";
NSString * const longitudeKey = @"long"; 

@implementation BartStationStore
@synthesize nearbyStations;

+ (BartStationStore *)sharedStore {
    static BartStationStore *stationStore = nil;
    if (!stationStore){
        // set up the singleton instance
        stationStore = [[BartStationStore alloc] init];
        stationStore.nearbyStations = [NSMutableArray array];
        stationStore.selectedStationIndices = [NSMutableArray
                                               arrayWithObjects:[NSNumber numberWithInt:-1],
                                               [NSNumber numberWithInt:-1], nil];
    }
    return stationStore;
}

- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion: (void (^)(NSArray *stations, NSError *err))block {

    // set up the HTTP GET request to retrieve nearby stations of the given
    // location.
    CLLocationCoordinate2D coords = currentLocation.coordinate;
    NSString *urlString = [NSString stringWithFormat:bartStationUrlTemplate,
                           coords.latitude, coords.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    OnTimeConnection *connection = [[OnTimeConnection alloc] initWithRequest:req];

    // define an outer completion block.
    // this block processes the HTTP response and stores the retrieved nearby
    // stations; it also calls the input parameter block to perform any additional
    // task.
    void (^processNearbyStations)(NSDictionary *stationsData, NSError *err) =
    ^void(NSDictionary *stationData, NSError *err){
        // First clear out the nearby stations.
        [self.nearbyStations removeAllObjects];

        NSValue *isSuccessful = stationData[successKey];
        if (!err){
            if (isSuccessful){
                // process stations                
                for (NSDictionary *stationDict in stationData[stationDictKey]) {
                    BartStation *station = [[BartStation alloc] init];
                    station.stationId = stationDict[stationIdKey];
                    station.stationName = stationDict[stationNameKey];
                    station.streetAddress = stationDict[stationAddressKey];
                    NSArray *locationCoords = stationDict[stationLocationKey];
                    if (locationCoords && [locationCoords count] == 2) {
                         station.location = CLLocationCoordinate2DMake([locationCoords[1] floatValue],
                                                                       [locationCoords[0] floatValue]);
                    }

                    [self.nearbyStations addObject:station];
                }
            } else {
                NSLog(@"success returned false");
                err = [NSError errorWithDomain:@"Server error" code:1 userInfo:nil];
            }
        } else {
            NSLog(@"error was returned for getNearbyStations: %@", err);
        }
        if (block){
            block(self.nearbyStations, err);
        }
    };
    [connection setCompletionBlock:processNearbyStations];
    [connection start];
    NSLog(@"get location for %@", currentLocation);
}

- (NSArray *)nearbyStations:(NSInteger)numStations {
    NSArray *stations = self.nearbyStations;
    // making sure that numStations never exceeds the available station number
    numStations = numStations > [stations count] ? [stations count] : numStations;

    NSRange range;
    range.location = 0;
    range.length = numStations;
    return [stations subarrayWithRange:range];
}

- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex {
    if (groupIndex < [self.selectedStationIndices count]){
        // make sure the group index is within the expected range
        if (stationIndex < [self.nearbyStations count]){
            // also check that the station index is within the number of
            // available nearby stations.
            NSNumber *selectedStationIndex = [NSNumber numberWithInt:stationIndex];
            [self.selectedStationIndices replaceObjectAtIndex:groupIndex
                                                   withObject:selectedStationIndex];
        } else {
            NSLog(@"station index is higher than nearby station count");
        }
    } else {
        NSLog(@"group index is higher than selected station index count");
    }
}

-(Station *)getSelecedStation:(NSInteger)groupIndex {
    NSNumber *selectedStationIndex = self.selectedStationIndices[groupIndex];
    NSInteger index = [selectedStationIndex integerValue];
    if (index < 0){
        // if no selection was made for the given group, simply return nil
        return nil;
    }
    return self.nearbyStations[[selectedStationIndex integerValue]];
}

- (void)resetCurrentSelectedStations {
    for (NSInteger i = 0; i < [self.selectedStationIndices count]; ++i){
        NSNumber *unselectedStationIndex = [NSNumber numberWithInt:-1];
        [self.selectedStationIndices replaceObjectAtIndex:i
                                               withObject:unselectedStationIndex];
    }
}

- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSDictionary *notificationData, NSError *err))block {
    // set up the HTTP POST request for the notification request
    NSURL *url = [NSURL URLWithString:bartNotificationUrl];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData
                                                       options:0
                                                         error:nil];
    
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:postData];
    [req setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    OnTimeConnection *connection = [[OnTimeConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection start];
    NSLog(@"request notification for %@", requestData);
}
@end
