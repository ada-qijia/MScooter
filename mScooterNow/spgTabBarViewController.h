//
//  spgTabBarViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgMScooterCommon.h"
#import "spgBLEService.h"
#import <MapKit/MapKit.h>
//#import "spgMScooterUtilities.h"

@protocol spgScooterPresentationDelegate <NSObject>

@optional

//for both dashboard and AR
-(void)updateConnectionState:(BOOL) connected;
-(void)updateSpeed:(float)speed;
-(void)updateBattery:(float)battery;
-(void)updateMileage:(int)mileage;

//only for AR mode
-(void)cameraTriggered:(SBSCameraCommand)commandType;
-(void)modeChanged;

-(void)powerStateReturned:(CBPeripheral *)peripheral result:(PowerState) currentState;
-(void)updateCertifyState:(BOOL) certified;

@end


@interface spgTabBarViewController : UITabBarController <UITabBarControllerDelegate,spgBLEServicePeripheralDelegate,CLLocationManagerDelegate>

@property (nonatomic, weak) id<spgScooterPresentationDelegate> scooterPresentationDelegate;

-(void)showDashboardGauge;

@property PowerState currentPowerState;

@end
