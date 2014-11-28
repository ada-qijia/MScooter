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
//#import "spgMScooterUtilities.h"

@protocol spgScooterPresentationDelegate <NSObject>

@optional

//for both dashboard and AR
-(void)updateConnectionState:(BOOL) connected;
-(void)updateSpeed:(float)speed;
-(void)updateBattery:(float)battery;

//only for AR mode
-(void)cameraTriggered:(SBSCameraCommand)commandType;
-(void)modeChanged;

-(void)passwordCertified:(CBPeripheral *)peripheral result:(BOOL) correct;

@end


@interface spgTabBarViewController : UITabBarController <UITabBarControllerDelegate,spgBLEServicePeripheralDelegate>

@property (nonatomic, weak) id<spgScooterPresentationDelegate> scooterPresentationDelegate;

@end
