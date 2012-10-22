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

// Navigation bar related constants
static NSString * const OnTimeTitle = @"OnTime Bart";

// Table view constants
static NSString * const sourceHeader = @"From";
static NSString * const destinationHeader = @"To";
static NSString * const defaultCellText = @"Select station";

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
}

// handles the notification data retrieved from the server response
- (void)handleNotificationData:(NSDictionary *)notificationData;

// makes a notification request to the server with the given request data
- (void)makeNotificationRequest:(NSDictionary *)requestData;

@end

@implementation OnTimeViewController

// controller methods

// designated initializer
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
         notification:(NSDictionary *)notificationData {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];

        // set the initial notification data
        notificationData_ = notificationData;

        // set navigation bar title
        [[self navigationItem] setTitle:OnTimeTitle];
    }
    return self;
}

// overriding the parent class designated initializer
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil
                          bundle:nibBundleOrNil
                    notification:nil];
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
        headerTitle = sourceHeader;
    } else if (section == 1){
        headerTitle = destinationHeader;
    }
    return [headerTitle stringByAppendingString:@":"];
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }

    NSString *cellText = defaultCellText;

    // if station is selected show the station name as the cell text
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
    NSString *titleString = nil;
    if (groupIndex == 0) {
        stations = [[BartStationStore sharedStore] nearbyStations:limitedStationNumber];
        titleString = sourceHeader;
    } else {
        stations = [[BartStationStore sharedStore] nearbyStations];
        titleString = destinationHeader;
    }
    
    // block code to execute when the selection is made
    void (^stationSelectionMade)() = ^void(NSInteger stationIndex) {
        [[BartStationStore sharedStore] selectStation:stationIndex inGroup:groupIndex];
        [tableView reloadData];
    };
    StationChoiceViewController *scvc = [[StationChoiceViewController alloc]
                                         initWithStations:stations
                                         withTitle:titleString
                                         withCompletion:stationSelectionMade];
    [[self navigationController] pushViewController:scvc animated:YES];
}

// action methods

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
    
    requestData[sourceStationKey] = [sourceStation stationId];
    requestData[destinationStationKey] = [destinationStation stationId];
    
    CLLocationCoordinate2D coords = [[locationManager location] coordinate];
    NSString *longitude = [NSString stringWithFormat:@"%f", coords.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f", coords.latitude];
    requestData[longitudeKey] = longitude;
    requestData[latitudeKey] = latitude;

    [self makeNotificationRequest:requestData];
}

// private helper methods

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

    id successValue = [notificationData objectForKey:successKey];
    if (![successValue boolValue]){
        int errorCode = [[notificationData objectForKey:errorCodeKey] intValue];
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
        CLLocationCoordinate2D coords = [[locationManager location] coordinate];
        NSString *longitude = [NSString stringWithFormat:@"%f", coords.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%f", coords.latitude];
        requestData[longitudeKey] = longitude;
        requestData[latitudeKey] = latitude;

        [self makeNotificationRequest:requestData];
    }
}
@end
