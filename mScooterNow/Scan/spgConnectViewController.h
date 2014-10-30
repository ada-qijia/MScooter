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

@property (nonatomic) BOOL isPeripheralKnown;

@property (weak, nonatomic) IBOutlet UIImageView *scooterOutline;
@property (weak, nonatomic) IBOutlet UIImageView *scooterEntity;
@property (weak, nonatomic) IBOutlet UIImageView *unlockHalo;
@property (weak, nonatomic) IBOutlet UIButton *unlockButton;
@property (weak, nonatomic) IBOutlet UIImageView *phone;
@property (weak, nonatomic) IBOutlet UILabel *scooterName;
@property (weak, nonatomic) IBOutlet UIImageView *connectionImage;
@property (weak, nonatomic) IBOutlet UIView *connectionView;
@property (weak, nonatomic) IBOutlet UIView *powerOnView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIImageView *powerOnCircleImage;

- (IBAction)unlockClicked:(UIButton *)sender;
- (IBAction)backClicked:(id)sender;
- (IBAction)closeClicked:(UIButton *)sender;

@end
