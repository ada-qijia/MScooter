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

typedef enum:NSUInteger
{
    ARModeCool,
    ARModeList,
    ARModeNormal
}ARMode;

@interface spgDashboardViewController : UIViewController<spgBLEServicePeripheralDelegate>

@property (weak,nonatomic) CBPeripheral *peripheral;
@property (strong,nonatomic) spgBLEService *bleService;

@property (weak, nonatomic) IBOutlet UIView *warningView;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;
@property (weak, nonatomic) IBOutlet UIButton *modeButton;
@property (weak, nonatomic) IBOutlet UIButton *camButton;

@property (weak, nonatomic) IBOutlet UIView *ARModesView;
@property (weak, nonatomic) IBOutlet UILabel *currentModeLabel;
@property (weak, nonatomic) IBOutlet UIButton *modesSwitchButton;

- (IBAction)RetryClicked:(id)sender;
- (IBAction)lightClicked:(UIButton *)sender;
- (IBAction)powerOff:(UIButton *)sender;
- (IBAction)switchMode:(UIButton *)sender;
- (IBAction)switchCam:(id)sender;
- (IBAction)switchARMode:(UIButton *)sender;
- (IBAction)showARModes:(id)sender;

@end
