//
//  OnTimeViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface OnTimeViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    CLLocationManager *locationManager;
    
    __weak IBOutlet MKMapView *userMapView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIButton *requestNotificationButton;
    __weak IBOutlet UISegmentedControl *methodToGetToStation;
    __weak IBOutlet UITableView *tableView;
}

// designated initializer
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
         notification:(NSDictionary *)notificationData;

// Action for when the notification button is pressed.
- (IBAction)requestNotification:(id)sender;

// Processes a pending notification
- (void)processPendingNotification:(NSDictionary *)notificationData;

@end
