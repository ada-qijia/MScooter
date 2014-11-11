//
//  spgConnectViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/22/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgMScooterCommon.h"
#import "spgBLEService.h"
#import "spgPinViewController.h"

@interface spgConnectViewController : spgPinViewController<spgBLEServicePeripheralDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *scooterEntity;
@property (weak, nonatomic) IBOutlet UIImageView *phone;
@property (weak, nonatomic) IBOutlet UILabel *scooterName;
@property (weak, nonatomic) IBOutlet UIImageView *connectionImage;
@property (weak, nonatomic) IBOutlet UIView *connectionView;
@property (weak, nonatomic) IBOutlet UIView *powerOnView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIImageView *powerOnCircleImage;

- (IBAction)backClicked:(id)sender;
- (IBAction)closeClicked:(UIButton *)sender;

@end
