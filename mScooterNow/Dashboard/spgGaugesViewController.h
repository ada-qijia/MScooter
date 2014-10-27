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
@property (weak, nonatomic) IBOutlet WMGaugeView *batteryGaugeView;
@property (weak, nonatomic) IBOutlet WMGaugeView *distanceGaugeView;

-(void)rotateLayout:(BOOL)portrait;

@end
