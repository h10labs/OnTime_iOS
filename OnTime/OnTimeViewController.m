//
//  OnTimeViewController.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeViewController.h"

@interface OnTimeViewController ()

@end

@implementation OnTimeViewController

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
    [activityIndicator stopAnimating];
    [self getNearbyStations:location];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [activityIndicator startAnimating];
    [userMapView setShowsUserLocation:YES];
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

- (IBAction)requestNotification:(id)sender {
    NSString *methodString = [methodToGetToStation titleForSegmentAtIndex:[methodToGetToStation selectedSegmentIndex]];
    NSLog(@"requesting, with method of %@", methodString);
}

- (void)getNearbyStations:(CLLocation *)currentLocation {
    NSLog(@"get location for %@", currentLocation);
}

@end
