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
@synthesize title = title_;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
               withTitle:(NSString *)title {
    self = [super init];
    if (self) {
        coordinate_ = coordinate;
        title_ = title;
    }
    return self;
}

- (id)init {
    // Invalid annotation
    return [self initWithCoordinate:CLLocationCoordinate2DMake(0, 0)
                          withTitle:nil];
}

@end
