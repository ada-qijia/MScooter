//
//  spgDashboardViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgDashboardViewController.h"
#import "spgScanViewController.h"

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateConnectedUIState];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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
        [self backToScanViewController];
    }
    else//power off
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Are you sure to power off your scooter?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Power Off", nil];
        [alert show];
    }
}

-(void)backToScanViewController
{
    UIViewController *currentVC=self;
    while (currentVC && ![currentVC isKindOfClass:[spgScanViewController class]]) {
        [currentVC dismissViewControllerAnimated:NO completion:nil];
        currentVC=currentVC.presentingViewController;
    }
    
    if([currentVC isKindOfClass:[spgScanViewController class]])
    {
        spgScanViewController *scanVC=(spgScanViewController *)currentVC;
        scanVC.shouldRetry=YES;
    }
}

#pragma - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        spgBLEService *bleService=[spgBLEService sharedInstance];
        [bleService writePower:[spgMScooterUtilities getDataFromByte:249]];
        
        [self performSelector:@selector(disconnect) withObject:nil afterDelay:1];
    }
}

-(void)disconnect
{
    spgBLEService *bleService=[spgBLEService sharedInstance];
    [bleService disConnectPeripheral];
}

#pragma - spgScooterPresentationDelegate

-(void)updateConnectionState:(BOOL) connected
{
    [self updateConnectedUIState];
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

#pragma -utility

-(void)updateConnectedUIState
{
    CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    self.powerButton.enabled=!(currentState==CBPeripheralStateConnecting);
    self.powerButton.selected= currentState==CBPeripheralStateDisconnected;
    
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:0];
    [gaugesVC setGaugesEnabled:currentState==CBPeripheralStateConnected];
}

@end
