//
//  spgScanViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgMScooterDefinitions.h"
#import "spgBLEService.h"
#import "spgConnectViewController.h"

@interface spgScanViewController : UIViewController <spgBLEServiceDiscoverPeripheralsDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL shouldRetry;

@property (weak, nonatomic) IBOutlet UIImageView *radarImage;

@property (weak, nonatomic) IBOutlet UIView *scopeView;
@property (weak, nonatomic) IBOutlet UIView *scooterView;
@property (weak, nonatomic) IBOutlet UIButton *preButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)pickupClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)preClicked:(id)sender;
- (IBAction)nextClicked:(id)sender;

@end
