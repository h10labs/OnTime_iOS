//
//  StationChoiceViewController.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/26/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "StationChoiceViewController.h"
#import "Station.h"

static NSString * const backLabel = @"Back";

@interface StationChoiceViewController () {
    NSArray *stationsArray_;
    Station *selectedStation_;
    void (^selectionMade_)(int stationIndex);
}

@end

@implementation StationChoiceViewController

- (id)initWithStations:(NSArray*)stations
             withTitle:(NSString *)title
         withSelection:(Station *)selectedStation
        withCompletion:(void (^)(int))block{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self){
        stationsArray_ = stations;
        selectionMade_ = block;
        selectedStation_ = selectedStation;
        // set up the navigation bar content
        [[self navigationItem] setTitle:title];
        [[[self navigationItem] rightBarButtonItem] setTitle:backLabel];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    // overriding the parent class designated initializer
    return [self initWithStations:nil
                        withTitle:nil
                    withSelection:nil
                   withCompletion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stationsArray_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    Station *station = [stationsArray_ objectAtIndex:[indexPath row]];
    NSString *cellText = [station stationName];
    NSString *cellDetailText = [station streetAddress];
    [[cell textLabel] setText:cellText];
    [[cell detailTextLabel] setText:cellDetailText];

    if (station == selectedStation_) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected row is %d", [indexPath row]);
    if (selectionMade_){
        selectionMade_([indexPath row]);
    }
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
