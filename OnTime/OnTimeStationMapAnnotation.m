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
@synthesize subtitle = subtitle_;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
               withTitle:(NSString *)title
            withSubtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        coordinate_ = coordinate;
        title_ = title;
        subtitle_ = subtitle;
    }
    return self;
}

- (id)init {
    // Invalid annotation
    return [self initWithCoordinate:CLLocationCoordinate2DMake(0, 0)
                          withTitle:nil
                       withSubtitle:nil];
}

@end
