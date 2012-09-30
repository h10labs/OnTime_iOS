//
//  BartStationStore.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BartStation.h"
#import "OnTimeManagerProtocol.h"

extern NSString * const methodKey;
extern NSString * const sourceStationKey;
extern NSString * const destinationStationKey;

@interface BartStationStore : NSObject <OnTimeManagerProtocol>

@property (nonatomic, strong) NSMutableArray *nearbyStations;
@property (nonatomic, strong) NSMutableArray *selectedStationIndices;
@end
