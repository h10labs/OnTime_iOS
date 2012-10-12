//
//  StationChoiceViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/26/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationChoiceViewController : UITableViewController {
    NSArray *stationsArray;
    void (^selectionMade)(int stationIndex);
}

// designated initializer
- (id)initWithStations:(NSArray *) stations
             withTitle:(NSString *) title
        withCompletion:(void (^)(int stationIndex))block;

@end
