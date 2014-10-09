//
//  spgDashboardViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgBLEService.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface spgDashboardViewController : UIViewController<spgBLEServicePeripheralDelegate>

@property (weak,nonatomic) CBPeripheral *peripheral;
@property (strong,nonatomic) spgBLEService *bleService;

@property (weak, nonatomic) IBOutlet UIView *camButtonsView;
@property (weak, nonatomic) IBOutlet UIView *warningView;
@property (weak, nonatomic) IBOutlet UIButton *modeSwitchButton;

- (IBAction)RetryClicked:(id)sender;
- (IBAction)lightClicked:(UIButton *)sender;
- (IBAction)powerOff:(UIButton *)sender;
- (IBAction)switchCam:(UIButton *)sender;
- (IBAction)switchMode:(UIButton *)sender;
- (IBAction)captureMedia:(id)sender;

@end
