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

//NSString * const bartStationUrlTemplate = @"http://ontime.nodejitsu.com/bart/locate/?lat=%f&long=%f";
NSString * const bartStationUrlTemplate = @"http://localhost:8000/bart/locate/?lat=%f&long=%f";
NSString * const bartNotificationUrl = @"http://localhost:8000/bart/notify";

// keys for stations json objects
NSString * const successKey = @"success";
NSString * const stationDictKey = @"stations";
NSString * const stationIdKey = @"id";
NSString * const stationNameKey = @"name";
NSString * const stationAddressKey = @"address";

// keys for notification request
NSString * const methodKey = @"method";
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
        [stationStore setNearbyStations:[[NSMutableArray alloc] init]];
        [stationStore setSelectedStationIndices:[NSMutableArray
                                                 arrayWithObjects:[NSNumber numberWithInt:-1],
                                                 [NSNumber numberWithInt:-1], nil]];
    }
    return stationStore;
}

- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion: (void (^)(NSArray *stations, NSError *err))block {

    // set up the HTTP GET request to retrieve nearby stations of the given
    // location.
    CLLocationCoordinate2D coords = [currentLocation coordinate];
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
        NSValue *isSuccessful = [stationData objectForKey:successKey];
        if (!err){
            if (isSuccessful){
                // process stations                
                for (NSDictionary *stationDict in [stationData objectForKey:stationDictKey]){
                    BartStation *station = [[BartStation alloc] init];
                    [station setStationId:[stationDict objectForKey:stationIdKey]];
                    [station setStationName:[stationDict objectForKey:stationNameKey]];
                    [station setStreetAddress:[stationDict objectForKey:stationAddressKey]];
                    [[self nearbyStations] addObject:station];
                }
            } else {
                NSLog(@"success returned false");
                err = [NSError errorWithDomain:@"Server error" code:1 userInfo:nil];
            }
        } else {
            NSLog(@"error was returned for getNearbyStations");
        }
        if (block){
            block([self nearbyStations], err);
        }
    };
    [connection setCompletionBlock:processNearbyStations];
    [connection start];
    NSLog(@"get location for %@", currentLocation);
}

- (NSArray *)nearbyStations:(NSInteger)numStations {
    NSArray *stations = [self nearbyStations];
    // making sure that numStations never exceeds the available station number
    numStations = numStations > [stations count] ? [stations count] : numStations;

    NSRange range;
    range.location = 0;
    range.length = numStations;
    NSArray *limitedStations = [stations subarrayWithRange:range];
    return limitedStations;
}

- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex {
    if (groupIndex < [[self selectedStationIndices] count]){
        // make sure the group index is within the expected range
        if (stationIndex < [[self nearbyStations] count]){
            // also check that the station index is within the number of
            // available nearby stations.
            NSNumber *selectedStationIndex = [NSNumber numberWithInt:stationIndex];
            [[self selectedStationIndices] replaceObjectAtIndex:groupIndex
                                                     withObject:selectedStationIndex];
        } else {
            NSLog(@"station index is higher than nearby station count");
        }
    } else {
        NSLog(@"group index is higher than selected station index count");
    }
}

-(Station *)getSelecedStation:(NSInteger)groupIndex {
    NSNumber *selectedStationIndex =  [[self selectedStationIndices] objectAtIndex:groupIndex];
    NSInteger index = [selectedStationIndex integerValue];
    if (index < 0){
        // if no selection was made for the given group, simply return nil
        return nil;
    }
    BartStation * station = [[self nearbyStations]
                             objectAtIndex:[selectedStationIndex integerValue]];
    return station;
}

- (void)resetCurrentSelectedStations {
    for (NSInteger i = 0; i < [[self selectedStationIndices] count]; ++i){
        NSNumber *unselectedStationIndex = [NSNumber numberWithInt:-1];
        [[self selectedStationIndices] replaceObjectAtIndex:i
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
