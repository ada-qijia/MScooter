//
//  spgGaugesViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMGaugeView.h"
#import "spgMScooterDefinitions.h"
#import "spgCamViewController.h"
#import "spgTabBarViewController.h"
#import "spgMScooterCommon.h"

@interface spgGaugesViewController : UIViewController <spgScooterPresentationDelegate>

@property (weak, nonatomic) IBOutlet UIView *SpeedView;
@property (weak, nonatomic) IBOutlet UIView *BatteryView;
@property (weak, nonatomic) IBOutlet UIView *RangeView;

@property (weak, nonatomic) IBOutlet WMGaugeView *speedGaugeView;

@property (weak, nonatomic) IBOutlet UIImageView *batteryBgImage;
@property (weak, nonatomic) IBOutlet UILabel *BatteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *DistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *SpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *DistanceUnitLabel;

@property (weak, nonatomic) IBOutlet UIButton *PowerButton;

- (IBAction)ChangePowerState:(UIButton *)sender;

-(void)setGaugesEnabled:(BOOL)enabled;
-(void)updatePowerState:(PowerState)state;

@end
