//
//  spgAppDelegate.m
//  mScooterNow
//
//  Created by v-qijia on 9/17/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgAppDelegate.h"
#import "spgMScooterCommon.h"
#import "spgIntroductionViewController.h"
#import "spgTabBarViewController.h"
#import "spgScanViewController.h"

@implementation spgAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //set the default scenario mode to campus
    if(![spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey])
    {
        [spgMScooterUtilities savePreferenceWithKey:kMyScenarioModeKey value:kScenarioModeCampus];
    }
    
    //whether show user guide or main dashboard
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSString *notFirstUse=[spgMScooterUtilities getPreferenceWithKey:kNotFirstUseKey];
    if(!notFirstUse || ![notFirstUse isEqualToString:@"YES"])
    {
        self.window.rootViewController= [storyboard instantiateViewControllerWithIdentifier:@"spgIntroductionVCID"];
    }
    else
    {
        spgTabBarViewController *tabBarVC=[storyboard instantiateViewControllerWithIdentifier:@"spgTabBarControllerID"];
        tabBarVC.selectedIndex=1;
        self.window.rootViewController=tabBarVC;
    }
    
    /*
     spgScanViewController *scanVC=[[spgScanViewController alloc] initWithNibName:@"spgScan" bundle:nil];
     self.window.rootViewController=scanVC;
     */
    
    [self.window makeKeyAndVisible];
    [self.window setTintColor:ThemeColor];
    
    //upload location
    [self uploadCurrentLocation:YES];
    
    return YES;
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
    
    [self uploadCurrentLocation:NO];
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
    [spgMScooterUtilities savePreferenceWithKey:kAutoReconnectUUIDKey value:nil];
}

-(void)uploadCurrentLocation:(BOOL)open
{
    NSString *uniqueIdentifier= [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    Byte isOpen=!open;
    NSString *scooterName=[spgMScooterUtilities getPreferenceWithKey:kScooterNameKey];
    
    CLLocationManager *locationManager=[[CLLocationManager alloc] init];
    CLLocation *loc= locationManager.location;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://crecord.chinacloudsites.cn/Home/SetData?CarId=%@&PhoneId=%@&Type=%d&Lng=%f&Lat=%f",scooterName,uniqueIdentifier,isOpen,loc.coordinate.longitude,loc.coordinate.latitude]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             NSLog(@"upload current location error: %@",connectionError);
         }
     }];
    
    locationManager=nil;
}

@end
