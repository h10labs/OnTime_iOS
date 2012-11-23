//
//  OnTimeStationMapAnnotation.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 11/22/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface OnTimeStationMapAnnotation : NSObject <MKAnnotation>

// Designated initializer
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
               withTitle:(NSString *)title
            withSubtitle:(NSString *)subtitle;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@end
