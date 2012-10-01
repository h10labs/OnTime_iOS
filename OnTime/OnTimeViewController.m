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
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // currently only holds one row in each section
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    // currently there are two sections: source and destination
    return 2;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
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

    NSString *cellText = @"select station";
    Station *station = [[BartStationStore sharedStore] getSelecedStation:[indexPath section]];
    if (station){
        cellText = [station stationName];
    }
    [[cell textLabel] setText:cellText];
    return cell;
}

// table view delegate overrides
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger groupIndex = [indexPath section];
    
    NSArray *stations = nil;
    if (groupIndex == 0) {
        stations = [[BartStationStore sharedStore] nearbyStations:limitedStationNumber];
    } else {
        stations = [[BartStationStore sharedStore] nearbyStations];
    }
    
    // block code to execute when the selection is made
    void (^stationSelectionMade)() = ^void(NSInteger stationIndex) {
        [[BartStationStore sharedStore] selectStation:stationIndex inGroup:groupIndex];
        [tableView reloadData];
    };
    StationChoiceViewController *scvc = [[StationChoiceViewController alloc]
                                         initWithStations:stations
                                         withCompletion:stationSelectionMade];
    [[self navigationController] pushViewController:scvc animated:YES];
}

// action methods

- (IBAction)requestNotification:(id)sender {
    NSString *methodString = [methodToGetToStation
                              titleForSegmentAtIndex:[methodToGetToStation selectedSegmentIndex]];
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc] init];
    [requestData setObject:methodString forKey:methodKey];
    
    BartStation *sourceStation = (BartStation *)[[BartStationStore sharedStore]
                                                 getSelecedStation:0];
    BartStation *destinationStation = (BartStation *)[[BartStationStore sharedStore]
                                                      getSelecedStation:1];
    // error checking
    if (!sourceStation || !destinationStation){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not a valid trip"
                                                     message:@"Please select source and destination"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return;
    } else if (sourceStation == destinationStation) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not a valid trip"
                                                    message:@"Please pick two different stations"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [av show];
        return;
    }
    
    [requestData setObject:[sourceStation stationId] forKey:sourceStationKey];
    [requestData setObject:[destinationStation stationId] forKey:destinationStationKey];
    
    CLLocationCoordinate2D coords = [[locationManager location] coordinate];
    NSString *longitude = [NSString stringWithFormat:@"%f", coords.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f", coords.latitude];
    [requestData setObject:longitude forKey:longitudeKey];
    [requestData setObject:latitude forKey:latitudeKey];
    void (^registerNotification)(NSDictionary *notificationData, NSError *err) =
        ^void(NSDictionary *notificationData, NSError *err) {
            NSLog(@"response data is %@", notificationData);
            // create local notification
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            NSDate *scheduledTime = [NSDate dateWithTimeIntervalSinceNow:10.0];
            [notification setFireDate:scheduledTime];
            [notification setAlertAction:@"OnTime!"];
            [notification setAlertBody:@"Leave now!"];
            [notification setHasAction:NO];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    };
    [[BartStationStore sharedStore] requestNotification:requestData
                                         withCompletion:registerNotification];
}

@end
