//
//  spgDashboardViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "spgGaugesViewController.h"
#import "spgTabBarViewController.h"

@interface spgDashboardViewController : UIViewController<spgScooterPresentationDelegate>

@property (weak, nonatomic) IBOutlet UIView *ARView;
@property (weak, nonatomic) IBOutlet UIView *GaugeView;
@property (weak, nonatomic) IBOutlet UIView *topControllerView;
@property (weak, nonatomic) IBOutlet UIImageView *connectedImage;

/*
- (IBAction)powerOn:(UIButton *)sender;
*/
-(void)showGauge;

@end
