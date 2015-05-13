//
//  spgAppDelegate.h
//  mScooterNow
//
//  Created by v-qijia on 9/17/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <CoreLocation/CoreLocation.h>

@interface spgAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *wbToken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

//@property (nonatomic) CLLocationManager *locationManager;
@end
