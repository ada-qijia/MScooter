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
    DashboardMode currentMode;
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
    
    UISwipeGestureRecognizer *horizontalLeftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalLeftSwipe:)];
    horizontalLeftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:horizontalLeftSwipe];
    
    UISwipeGestureRecognizer *horizontalRightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalRightSwipe:)];
    horizontalRightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontalRightSwipe];
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

#pragma mark - gesture methods

-(void)reportHorizontalLeftSwipe:(UIGestureRecognizer *)recognizer
{
    [self switchViewMode:YES];
}

-(void)reportHorizontalRightSwipe:(UIGestureRecognizer *)recognizer
{
    [self switchViewMode:NO];
}

-(void)switchViewMode:(BOOL) next
{
    int modeCount=5;
    UIView *currentView=currentMode==Gauge?self.GaugeView:self.ARView;
    
    DashboardMode toMode=next?(currentMode+1)%modeCount:(currentMode-1+modeCount)%modeCount;
    UIView *nextView=toMode==Gauge?self.GaugeView:self.ARView;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype =next? kCATransitionFromRight:kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [currentView.layer addAnimation:transition forKey:nil];
    [nextView.layer addAnimation:transition forKey:nil];
    
    [[self getViewOfARMode:currentMode] setHidden:YES];
    [[self getViewOfARMode:toMode] setHidden:NO];
    currentView.hidden=YES;
    nextView.hidden=NO;
    
    currentMode=toMode;
}

-(UIView *)getViewOfARMode:(DashboardMode) mode
{
    switch (mode) {
        case ARModeCool:
            return [self.ARView viewWithTag:11];//.ARInfoView;
        case ARModeList:
            return [self.ARView viewWithTag:10];//.ARListView;
        case ARModeMap:
            return [self.ARView viewWithTag:12];//.ARMapView;
        case ARModeNormal:
            return nil;
        default:
            return nil;
    }
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
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:1];
    [gaugesVC.speedGaugeView setValue:speed animated:YES duration:0.3];
}

-(void)updateBattery:(float) battery
{
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:1];
    gaugesVC.BatteryLabel.text=[NSString stringWithFormat:@"%0.f", battery];
    gaugesVC.DistanceLabel.text=gaugesVC.BatteryLabel.text;
    
    [gaugesVC setBatteryLow:battery<15];
}

-(void)modeChanged
{
    [self switchViewMode:YES];
}

#pragma -utility

-(void)updateConnectedUIState
{
    CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    self.powerButton.enabled=!(currentState==CBPeripheralStateConnecting);
    self.powerButton.selected= currentState==CBPeripheralStateDisconnected;
    
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:1];
    [gaugesVC setGaugesEnabled:currentState==CBPeripheralStateConnected];
}

@end
