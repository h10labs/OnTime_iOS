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
}

- (id)initWithStations:(NSArray *) stations;

@end
