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
#import "OnTimeNotification.h"
#import "OnTimeStationMapAnnotation.h"

// Navigation bar related constants
static NSString * const OnTimeTitle = @"OnTime Bart";

// Table view constants
static NSString * const sourceHeader = @"From";
static NSString * const destinationHeader = @"To";

static NSString * const defaultFromCellText = @"From: ";
static NSString * const defaultToCellText = @"To: ";

// Error titles and messages
static NSString * const invalidTripTitle = @"Not a valid trip";
static NSString * const missingStationMessage =
    @"Please select source and destination.";
static NSString * const identicalStationMessage =
    @"Please pick two different stations.";

static NSString * const nearbyStationErrorTitle = @"Could not get nearby stations.";
static NSString * const notificationErrorTitle = @"Could not submit notification request.";
static NSString * const errorMessage = @"Please try again later.";
static NSString * const errorButtonTitle = @"OK";

static NSString * const missingParameterMessage = @"Not all parameters were provided.";
static NSString * const failedToCreateNoficationMessage = @"Failed to create notification.";
static NSString * const noTimeAvailableMessage = @"No time is available.";
static NSString * const defaultNotificationErrorMessage= @"An error occurred. Please try again.";

// Notification related constants
static NSString * const noNotificationTitle = @"No Notification";

// Notification data dictionary keys
static NSString * const successKey = @"success";
static NSString * const errorCodeKey = @"errorCode";


@interface OnTimeViewController () {
    NSDictionary *notificationData_;
    CLLocationManager *locationManager_;
    NSMutableSet *tableRowsToUpdate_;
    OnTimeStationMapAnnotation *sourceStationAnnotation_;
}

// handles the notification data retrieved from the server response
- (void)handleNotificationData:(NSDictionary *)notificationData;

// makes a notification request to the server with the given request data
- (void)makeNotificationRequest:(NSDictionary *)requestData;

@end

@implementation OnTimeViewController


# pragma mark - inits


// designated initializer
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
         notification:(NSDictionary *)notificationData {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locationManager_ = [[CLLocationManager alloc] init];
        [locationManager_ setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [locationManager_ setDistanceFilter:100];

        // Set the initial notification data.
        notificationData_ = notificationData;

        // Initialize the set of rows to update when the view appears.
        // This is used for cases like when users has made a source station.
        tableRowsToUpdate_ = [NSMutableSet set];

        // Set navigation bar title.
        self.navigationItem.title = OnTimeTitle;
    }
    return self;
}

// Overriding the parent class designated initializer
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil
                          bundle:nibBundleOrNil
                    notification:nil];
}


#pragma mark - view cycle methods


- (void)viewDidLoad {
   [userMapView setShowsUserLocation:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Update the rows that needs to be updated.
    if ([tableRowsToUpdate_ count] > 0) {
        [tableView reloadRowsAtIndexPaths:[tableRowsToUpdate_ allObjects]
                         withRowAnimation:UITableViewRowAnimationRight];
        [tableRowsToUpdate_ removeAllObjects];

        // Animate the map region change since when the table rows update is
        // required, then it also means that the map annotation location
        // has changed.
        CLLocation *stationLocation = [[CLLocation alloc]
                                       initWithCoordinate:sourceStationAnnotation_.coordinate
                                       altitude:0
                                       horizontalAccuracy:0
                                       verticalAccuracy:-1
                                       timestamp:[NSDate date]];
        CLLocationDistance distance =
            [locationManager_.location distanceFromLocation:stationLocation];
        MKCoordinateRegion region =
        MKCoordinateRegionMakeWithDistance(locationManager_.location.coordinate,
                                           distance * 2,
                                           distance * 2);
        [userMapView setRegion:region animated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - map view delegate methods


- (void)mapView:(MKMapView *)view didUpdateUserLocation:(MKUserLocation *)userLocation {
    static BOOL updateInProgress = NO;
    if (updateInProgress) {
        [activityIndicator stopAnimating];
        return;
    }
    updateInProgress = YES;
    [activityIndicator startAnimating];

    CLLocation *location = [userLocation location];
    CLLocationCoordinate2D coords = [location coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coords, 500, 500);
    [userMapView setRegion:region animated:YES];

    // callback method
    void (^displayNearbyStations)(NSArray *nearbyStations, NSError *err) =
    ^void(NSArray *nearbyStations, NSError *err){
        [activityIndicator stopAnimating];
        if (err) {
            // display the error message if retrieve nearby stations was
            // not successful
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nearbyStationErrorTitle
                                                                 message:errorMessage
                                                                delegate:nil
                                                       cancelButtonTitle:errorButtonTitle
                                                       otherButtonTitles:nil];
            [errorAlert show];
        } else if (notificationData_) {
            [self processPendingNotification:notificationData_];
            notificationData_ = nil;
        }
        updateInProgress = NO;
    };
    [[BartStationStore sharedStore] getNearbyStations:location
                                       withCompletion:displayNearbyStations];
}


#pragma mark - table view data source overrides


// table view data source overrides
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // currently only holds one row in each section
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    // currently there are two sections: source and destination
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }

    NSString *cellText = nil;
    switch (indexPath.section) {
    case 0:
        cellText = defaultFromCellText;
        break;
    case 1:
        cellText = defaultToCellText;
        break;
    default:
        cellText = defaultFromCellText;
    }

    // if station is selected show the station name as the cell text
    Station *station = [[BartStationStore sharedStore] getSelecedStation:indexPath.section];
    if (station){
        cellText = [cellText stringByAppendingString:station.stationName];
    }
    cell.textLabel.text = cellText;
    return cell;
}


#pragma mark - table view delegate overrides


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger groupIndex = indexPath.section;
    
    NSArray *stations = nil;
    NSString *titleString = nil;
    Station *selectedStation = nil;
    if (groupIndex == 0) {
        stations = [[BartStationStore sharedStore] nearbyStations:limitedStationNumber];
        titleString = sourceHeader;
        selectedStation = [[BartStationStore sharedStore] getSelecedStation:0];
    } else {
        stations = [[BartStationStore sharedStore] nearbyStations];
        titleString = destinationHeader;
        selectedStation = [[BartStationStore sharedStore] getSelecedStation:1];
    }
    
    // block code to execute when the selection is made
    void (^stationSelectionMade)() = ^void(NSInteger stationIndex) {
        [[BartStationStore sharedStore] selectStation:stationIndex
                                              inGroup:groupIndex];
        // Record that the table row designated by the given index path needs to
        // be updated.
        [tableRowsToUpdate_ addObject:indexPath];

        if (groupIndex == 0) {
            // If it was the source station that was selected, create a map
            // annotation that points to the source destination
            Station *selectedSourceStation =
                [[BartStationStore sharedStore] getSelecedStation:groupIndex];

            // Create an annotation if it doesn't already exist. Else simply
            // update the annotation coordinate which will get relfected in the
            // map view.
            if (!sourceStationAnnotation_) {
                sourceStationAnnotation_ =
                    [[OnTimeStationMapAnnotation alloc]
                     initWithCoordinate:selectedSourceStation.location
                              withTitle:selectedSourceStation.stationName
                           withSubtitle:selectedSourceStation.streetAddress
                     ];
                [userMapView addAnnotation:sourceStationAnnotation_];
            } else {
                // If the callout view is displayed, deselecting the
                // annotation closes it. This is done so that the call out view
                // is not going to be consistently shown even when we change
                // the annotation title dynamically.
                [userMapView deselectAnnotation:sourceStationAnnotation_
                                       animated:YES];
                sourceStationAnnotation_.coordinate = selectedSourceStation.location;
                sourceStationAnnotation_.title = selectedSourceStation.stationName;
                sourceStationAnnotation_.subtitle = selectedSourceStation.streetAddress;
            }
        }
    };
    StationChoiceViewController *scvc = [[StationChoiceViewController alloc]
                                         initWithStations:stations
                                         withTitle:titleString
                                         withSelection:selectedStation
                                         withCompletion:stationSelectionMade];
    [self.navigationController pushViewController:scvc animated:YES];

    // Deselect the row to avoid having the row highlighted
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - action methods


- (IBAction)requestNotification:(id)sender {
    NSString *methodString = [methodToGetToStation
                              titleForSegmentAtIndex:[methodToGetToStation selectedSegmentIndex]];
    NSMutableDictionary *requestData = [NSMutableDictionary dictionary];
    requestData[methodKey] = methodString;
    
    BartStation *sourceStation = (BartStation *)[[BartStationStore sharedStore]
                                                 getSelecedStation:0];
    BartStation *destinationStation = (BartStation *)[[BartStationStore sharedStore]
                                                      getSelecedStation:1];
    // error checking
    if (!sourceStation || !destinationStation){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:invalidTripTitle
                                                     message:missingStationMessage
                                                    delegate:nil
                                           cancelButtonTitle:errorButtonTitle
                                           otherButtonTitles:nil];
        [av show];
        return;
    } else if (sourceStation == destinationStation) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:invalidTripTitle
                                                     message:identicalStationMessage
                                                    delegate:nil
                                           cancelButtonTitle:errorButtonTitle
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    requestData[sourceStationKey] = sourceStation.stationId;
    requestData[destinationStationKey] = destinationStation.stationId;
    
    CLLocationCoordinate2D coords = [[locationManager_ location] coordinate];
    NSString *longitude = [NSString stringWithFormat:@"%f", coords.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f", coords.latitude];
    requestData[longitudeKey] = longitude;
    requestData[latitudeKey] = latitude;

    [self makeNotificationRequest:requestData];
}


#pragma mark - private helper methods


- (void)makeNotificationRequest:(NSDictionary *)requestData {
    void (^registerNotification)(NSDictionary *notificationData, NSError *err) =
    ^void(NSDictionary *notificationData, NSError *err) {
        if (err){
            // display the error message if retrieve nearby stations was
            // not successful
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:notificationErrorTitle
                                                                 message:errorMessage
                                                                delegate:nil
                                                       cancelButtonTitle:errorButtonTitle
                                                       otherButtonTitles:nil];
            [errorAlert show];
            return;
        }
        [self handleNotificationData:notificationData];

    };
    [[BartStationStore sharedStore] requestNotification:requestData
                                         withCompletion:registerNotification];
}

- (void)handleNotificationData:(NSDictionary *)notificationData {
    NSLog(@"response data is %@", notificationData);

    id successValue = notificationData[successKey];
    if (![successValue boolValue]){
        int errorCode = [notificationData[errorCodeKey] intValue];
        NSString *noNotificationErrorMessage = nil;
        switch (errorCode){
            case 1:
                noNotificationErrorMessage = missingStationMessage;
                break;
            case 2:
                noNotificationErrorMessage = failedToCreateNoficationMessage;
                break;
            case 3:
                noNotificationErrorMessage = noTimeAvailableMessage;
                break;
            default:
                noNotificationErrorMessage = defaultNotificationErrorMessage;
                break;
        }
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:noNotificationTitle
                                                             message:noNotificationErrorMessage
                                                            delegate:nil
                                                   cancelButtonTitle:errorButtonTitle
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }

    // Schedule the first available notification
    OnTimeNotification *notification =
        [[OnTimeNotification alloc] initWithNotificationData:notificationData];
    [notification scheduleNotification:0];

    // reset current selection since the notification was successful
    [[BartStationStore sharedStore] resetCurrentSelectedStations];
    [tableView reloadData];
}

- (void)processPendingNotification:(NSDictionary *)notificationData {
    if (notificationData) {
        NSLog(@"processing pending notification");
        NSMutableDictionary *requestData = [NSMutableDictionary dictionary];

        NSString *startStationId = nil;
        NSArray *nearbyStations = [[BartStationStore sharedStore] nearbyStations:1];
        if ([nearbyStations count] > 0) {
            BartStation *nearbyStation = nearbyStations[0];
            startStationId = nearbyStation.stationId;
        } else {
            startStationId = notificationData[kStartId];
        }

        requestData[sourceStationKey] = startStationId;
        requestData[destinationStationKey] = notificationData[kDestinationId];

        // TODO: Duplicated code.
        CLLocationCoordinate2D coords = [[locationManager_ location] coordinate];
        NSString *longitude = [NSString stringWithFormat:@"%f", coords.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%f", coords.latitude];
        requestData[longitudeKey] = longitude;
        requestData[latitudeKey] = latitude;

        [self makeNotificationRequest:requestData];
    }
}

@end
