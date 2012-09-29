//
//  OnTimeViewController.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeViewController.h"
#import "StationChoiceViewController.h"
#import "BartStationStore.h"

@interface OnTimeViewController ()

@end

@implementation OnTimeViewController

// controller methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    }
    return self;
}

- (void)mapView:(MKMapView *)view didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocation *location = [userLocation location];
    CLLocationCoordinate2D coords = [location coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coords, 500, 500);
    [userMapView setRegion:region animated:YES];
      
    // callback method
    void (^displayNearbyStations)(NSArray *nearbyStations, NSError *err) =
        ^void(NSArray *nearbyStations, NSError *err){
            [activityIndicator stopAnimating];
            NSLog(@"ready to display stations, %@", nearbyStations);
    };
    [[BartStationStore sharedStore] getNearbyStations:location
                                       withCompletion:displayNearbyStations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [activityIndicator startAnimating];
    [userMapView setShowsUserLocation:YES];
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


// table view data source overrides
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // currently only holds one row in each section
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // currently there are two sections: source and destination
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = nil;
    if (section == 0){
        headerTitle = @"Source";
    } else if (section == 1){
        headerTitle = @"Destination";
    }
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    
    // place holder for now
    NSString *cellText = nil;
    if ([indexPath section] == 0) {
        cellText = @"source";
    } else {
        cellText = @"destination";
    }
    [[cell textLabel] setText:cellText];
    return cell;
}

// table view delegate overrides
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *stations = [NSArray arrayWithObjects:@"station 1",
                         @"station 2", nil];
    StationChoiceViewController *scvc = [[StationChoiceViewController alloc]
                                         initWithStations:stations];
    [[self navigationController] pushViewController:scvc animated:YES];
}

// app related methods

- (IBAction)requestNotification:(id)sender {
    NSString *methodString = [methodToGetToStation
                              titleForSegmentAtIndex:[methodToGetToStation selectedSegmentIndex]];
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc] init];
    
    void (^registerNotification)(NSDictionary *notificationData, NSError *err) =
        ^void(NSDictionary *notificationData, NSError *err) {
        
    };
    [[BartStationStore sharedStore] requestNotification:requestData
                                         withCompletion:registerNotification];
    NSLog(@"requesting, with method of %@", methodString);
}

@end
