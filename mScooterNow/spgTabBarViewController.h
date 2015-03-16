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
//includes batteryState
-(void)updateBattery:(float)battery;
-(void)updateMileage:(int)mileage;

//only for AR mode
-(void)cameraTriggered:(SBSCameraCommand)commandType;
-(void)modeChanged;
//Returned
-(void)batteryStateChanged:(BatteryState)newState;

-(void)powerStateReturned:(CBPeripheral *)peripheral result:(PowerState) currentState;
-(void)updateCertifyState:(BOOL) certified;

@end


@interface spgTabBarViewController : UIViewController <spgBLEServicePeripheralDelegate,CLLocationManagerDelegate>

@property (nonatomic, weak) id<spgScooterPresentationDelegate> scooterPresentationDelegate;

-(void)showDashboardGauge;
-(void)setSelectedTabIndex:(NSInteger) index;
-(void)setBadge:(NSString*) value;

@property PowerState currentPowerState;
@property BatteryState currentBatteryState;

@property (weak, nonatomic) IBOutlet UIView *BottomBar;
- (IBAction)TabItemClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *momentsBadge;

@property (weak, nonatomic) IBOutlet UIButton *momentsBtn;
@property (weak, nonatomic) IBOutlet UIButton *dashboardBtn;
@property (weak, nonatomic) IBOutlet UIButton *meBtn;
@end
