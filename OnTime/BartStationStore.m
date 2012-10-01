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
    CLLocationCoordinate2D coords = [currentLocation coordinate];
    NSString *urlString = [NSString stringWithFormat:bartStationUrlTemplate,
                           coords.latitude, coords.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    OnTimeConnection *connection = [[OnTimeConnection alloc] initWithRequest:req];
    
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
            }
        } else {
            // handle error
            NSLog(@"error was returned for getNearbyStations");
        }
        if (block){
            block(nearbyStations, err);
        }
    };
    [connection setCompletionBlock:processNearbyStations];
    [connection start];
    NSLog(@"get location for %@", currentLocation);
}

- (NSArray *)nearbyStations:(NSInteger)numStations {
    NSArray *stations = [self nearbyStations];
    NSRange range;
    range.location = 0;
    range.length = numStations;
    NSArray *limitedStations = [stations subarrayWithRange:range];
    return limitedStations;
}

- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex {
    if (groupIndex < [[self selectedStationIndices] count]){
        if (stationIndex < [[self nearbyStations] count]){
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
        return nil;
    }
    BartStation * station = [[self nearbyStations]
                             objectAtIndex:[selectedStationIndex integerValue]];
    return station;
}

- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSDictionary *notificationData, NSError *err))block {
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
