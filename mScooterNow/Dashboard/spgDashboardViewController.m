//
//  spgDashboardViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgDashboardViewController.h"
#import "spgScanViewController.h"
#import "spgTabBarViewController.h"
#import "spgARViewController.h"

@interface spgDashboardViewController ()

@end

@implementation spgDashboardViewController
{
    spgTabBarViewController *tabBarVC;
}

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
    tabBarVC=(spgTabBarViewController *)self.tabBarController;//.parentViewController;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateConnectedUIState];
    
    tabBarVC.scooterPresentationDelegate=self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    tabBarVC.scooterPresentationDelegate=nil;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UI interaction

- (IBAction)powerOn:(UIButton *)sender {
    if(sender.selected)//power on
    {
        spgScanViewController *scanVC=[[spgScanViewController alloc] initWithNibName:@"spgScan" bundle:nil];
        
        [self presentViewController:scanVC animated:NO completion:nil];
    }
    else//power off
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Are you sure to power off your scooter?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Power Off", nil];
        [alert show];
    }
}

#pragma - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showARSegue"])
    {
        spgARViewController *arVC= segue.destinationViewController;
        arVC.tabBarVC=tabBarVC;
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
