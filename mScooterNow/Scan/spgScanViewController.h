//
//  spgScanViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgBLEService.h"
#import "spgPinViewController.h"
#import "spgDashboardViewController.h"

@interface spgScanViewController : spgPinViewController<spgBLEServiceDiscoverPeripheralsDelegate>

@property (nonatomic) BOOL shouldRetry;

@property (weak, nonatomic) IBOutlet UIImageView *radarImage;
@property (weak, nonatomic) IBOutlet UIImageView *scooterOutline;
@property (weak, nonatomic) IBOutlet UIImageView *scooterEntity;
@property (weak, nonatomic) IBOutlet UIImageView *unlockHalo;
@property (weak, nonatomic) IBOutlet UIButton *unlockButton;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIImageView *circlesBg;

-(IBAction)scooterClicked:(id)sender;
- (IBAction)retryClicked:(id)sender;

@end
