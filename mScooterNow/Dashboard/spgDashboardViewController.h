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

@interface spgDashboardViewController : UIViewController<spgScooterPresentationDelegate,spgBLEServiceDiscoverPeripheralsDelegate>

@property (weak, nonatomic) IBOutlet UIView *ARView;
@property (weak, nonatomic) IBOutlet UIView *GaugeView;
@property (weak, nonatomic) IBOutlet UIView *topControllerView;
@property (weak, nonatomic) IBOutlet UIImageView *connectedImage;
@property (weak, nonatomic) IBOutlet UIButton *camSwitchButton;
@property (weak, nonatomic) IBOutlet UILabel *scooterNameLabel;

- (IBAction)camSwitchClicked:(id)sender;

/*
- (IBAction)powerOn:(UIButton *)sender;
*/
-(void)showGauge;
- (IBAction)AddScooterClicked:(id)sender;

//test
- (IBAction)TakePhoto:(id)sender;
- (IBAction)RecordVideo:(id)sender;
- (IBAction)IdentifyPhone:(id)sender;
- (IBAction)ChangePowerMode:(UIButton *)sender;
- (IBAction)SendPwd:(id)sender;

@end
