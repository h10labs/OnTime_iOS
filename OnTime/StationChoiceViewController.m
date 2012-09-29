//
//  StationChoiceViewController.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/26/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "StationChoiceViewController.h"

@interface StationChoiceViewController ()

@end

@implementation StationChoiceViewController

- (id)initWithStations:(NSArray*)stations {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self){
        stationsArray = stations;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self initWithStations:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stationsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *cellText = [NSString stringWithFormat:@"station %d", [indexPath row]];
    [[cell textLabel] setText:cellText];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected row is %d", [indexPath row]);
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
