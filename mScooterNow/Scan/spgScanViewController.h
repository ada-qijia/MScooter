//
//  spgScanViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgMScooterDefinitions.h"
#import "spgBLEService.h"
#import "spgConnectViewController.h"

typedef enum:NSInteger
{
    BLEDeviceStateActive,
    BLEDeviceStateVague,
    BLEDeviceStateInactive
}BLEDeviceState;

@interface spgScanViewController : UIViewController <spgBLEServiceDiscoverPeripheralsDelegate>

@property (nonatomic) BOOL shouldRetry;

@property (weak, nonatomic) IBOutlet UIImageView *radarImage;
@property (weak, nonatomic) IBOutlet UIImageView *circlesImage;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@property (weak, nonatomic) IBOutlet UIView *foundView;
@property (weak, nonatomic) IBOutlet UIScrollView *devicesScrollView;
@property (weak, nonatomic) IBOutlet UIView *notFoundView;
@property (weak, nonatomic) IBOutlet UIView *scopeView;

@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
- (IBAction)pickupClicked:(id)sender;
- (IBAction)backClicked:(id)sender;


- (IBAction)scooterClicked:(UIButton *)sender;
- (IBAction)retryClicked:(id)sender;

@end
