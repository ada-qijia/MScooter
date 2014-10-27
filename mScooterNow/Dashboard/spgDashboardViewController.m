//
//  spgDashboardViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgDashboardViewController.h"

@interface spgDashboardViewController ()

@end

@implementation spgDashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UI interaction

- (IBAction)RetryClicked:(id)sender {
    /*
    spgScanViewController *root=(spgScanViewController *)self.presentingViewController;
    root.shouldRetry=YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
     */
}

- (IBAction)powerOff:(UIButton *)sender {
    //[self.bleService writePower:self.peripheral value:[self getData:249]];
    //give ble receiver some time to handle the signal before disconnect.
    [self performSelector:@selector(RetryClicked:) withObject:nil afterDelay:1];
}

#pragma - UI change

-(void)updateSpeed:(float) speed
{
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:0];
    [gaugesVC.speedGaugeView setValue:speed animated:YES duration:0.3];
}

-(void)updateBattery:(float) battery
{
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:0];
    [gaugesVC.batteryGaugeView setValue:battery animated:YES duration:0.3];
    [gaugesVC.distanceGaugeView setValue:battery animated:YES duration:0.3];
}

-(void)updateConnectionState:(BOOL) connected
{
}

-(void)setWarningBarHidden:(BOOL) hidden
{
    self.warningView.hidden=hidden;
}

@end
