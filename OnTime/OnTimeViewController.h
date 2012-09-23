//
//  OnTimeViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface OnTimeViewController : UIViewController <MKMapViewDelegate> {
    CLLocationManager *locationManager;
    
    IBOutlet MKMapView *userMapView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIButton *requestNotificationButton;
    __weak IBOutlet UISegmentedControl *methodToGetToStation;
}

- (void)getNearbyStations:(CLLocation *)currentLocation;
- (IBAction)requestNotification:(id)sender;
@end
