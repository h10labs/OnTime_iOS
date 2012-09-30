//
//  StationChoiceViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/26/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationChoiceViewController : UITableViewController {
    __weak NSArray *stationsArray;
    void (^selectionMade)(int stationIndex);
}

- (id)initWithStations:(NSArray *) stations
        withCompletion:(void (^)(int stationIndex))block;

@end
