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

@interface spgDashboardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *topControllerView;
@property (weak, nonatomic) IBOutlet UIView *warningView;

- (IBAction)RetryClicked:(id)sender;
- (IBAction)powerOff:(UIButton *)sender;

-(void)updateSpeed:(float) speed;
-(void)updateBattery:(float) battery;
-(void)updateConnectionState:(BOOL) connected;

@end
