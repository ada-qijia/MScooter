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
    if(sender.selected)//power on
    {
  
    }
    else//power off
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Are you sure to power off your scooter?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Power Off", nil];
        [alert show];
    }
}

#pragma - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        self.powerButton.selected=YES;
        spgBLEService *bleService=[spgBLEService sharedInstance];
        [bleService writePower:[spgMScooterUtilities getDataFromInt16:249]];
        
        [bleService disConnectPeripheral];
    }
    else
    {
        self.powerButton.selected=NO;
    }
}

#pragma - spgScooterPresentationDelegate

-(void)updateConnectionState:(BOOL) connected
{
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:0];
    [gaugesVC setGaugesEnabled:connected];
}

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
    
    [gaugesVC setBatteryLow:battery<15];
}

@end
