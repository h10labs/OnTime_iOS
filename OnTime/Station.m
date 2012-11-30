//
//  Station.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/28/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "Station.h"

@implementation Station

@synthesize stationId;
@synthesize stationName;
@synthesize location;
@synthesize streetAddress;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self stationName]];
}

@end
