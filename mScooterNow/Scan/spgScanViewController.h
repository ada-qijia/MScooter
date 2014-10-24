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


@interface spgScanViewController : UIViewController <spgBLEServiceDiscoverPeripheralsDelegate,UIScrollViewDelegate>

@property (nonatomic) BOOL shouldRetry;

@property (weak, nonatomic) IBOutlet UIImageView *radarImage;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@property (weak, nonatomic) IBOutlet UIView *foundView;
@property (weak, nonatomic) IBOutlet UIScrollView *devicesScrollView;
@property (weak, nonatomic) IBOutlet UIView *notFoundView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)scooterClicked:(id)sender;
- (IBAction)retryClicked:(id)sender;
- (IBAction)pageChanged:(UIPageControl *)sender;

@end
