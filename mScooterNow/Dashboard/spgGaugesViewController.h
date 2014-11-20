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

@interface spgGaugesViewController : UIViewController

@property (weak, nonatomic) IBOutlet WMGaugeView *speedGaugeView;

@property (weak, nonatomic) IBOutlet UIImageView *batteryBgImage;
@property (weak, nonatomic) IBOutlet UILabel *BatteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *DistanceLabel;

-(void)rotateLayout:(BOOL)portrait;

-(void)setGaugesEnabled:(BOOL)enabled;
-(void)setBatteryLow:(BOOL)low;

@end
