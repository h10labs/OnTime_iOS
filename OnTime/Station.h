//
//  Station.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/28/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Station : NSObject {
    
}

@property (nonatomic, strong) NSString *stationId;
@property (nonatomic, strong) NSString *stationName;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *streetAddress;

@end
