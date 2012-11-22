	//
//  OnTimeAppDelegate.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeAppDelegate.h"
#import "OnTimeViewController.h"
#import "OnTimeNotification.h"

static NSString * const kSnoozeTitle = @"Snooze";

@interface OnTimeAppDelegate () {
    OnTimeViewController *onTimeViewController_;

    // TODO: is this safe to keep only one instance of object?
    NSDictionary *receivedNotificationData_;
}

@end

@implementation OnTimeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // check if there is a location notification that is pending to be processed
    NSDictionary *notificationData = nil;
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        // sets in the view controller
        notificationData = notification.userInfo;
    }

    onTimeViewController_ = [[OnTimeViewController alloc] initWithNibName:@"OnTimeViewController"
                                                                   bundle:nil
                                                             notification:notificationData];

    UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:onTimeViewController_];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"Received local notification: %@", notification);

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[notification alertAction]
                                                 message:[notification alertBody]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    if ([notification.userInfo[kSnoozableKey] boolValue]) {
        // store the user info of the given notification
        receivedNotificationData_ = notification.userInfo;
        [av addButtonWithTitle:kSnoozeTitle];
    }
    [av show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle compare:kSnoozeTitle] == NSOrderedSame) {
        // Let the view controller handle the notification.
        [onTimeViewController_ processPendingNotification:receivedNotificationData_];
        
        // reset the notification info
        receivedNotificationData_ = nil;
    }
}

@end
