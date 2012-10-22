//
//  StationChoiceViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/26/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;

@interface StationChoiceViewController : UITableViewController

// designated initializer
- (id)initWithStations:(NSArray *) stations
             withTitle:(NSString *) title
         withSelection:(Station *)selectedStation
        withCompletion:(void (^)(int stationIndex))block;

@end
