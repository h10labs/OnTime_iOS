//
//  OnTimeStationMapAnnotation.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 11/22/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeStationMapAnnotation.h"

@implementation OnTimeStationMapAnnotation

@synthesize coordinate = coordinate_;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        coordinate_ = coordinate;
    }
    return self;
}

- (id)init {
    // Invalid coordinate
    return [self initWithCoordinate:CLLocationCoordinate2DMake(0, 0)];
}

@end
