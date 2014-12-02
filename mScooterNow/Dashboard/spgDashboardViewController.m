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
#import "spgBLEService.h"

@interface spgDashboardViewController ()

@end

@implementation spgDashboardViewController
{
    spgTabBarViewController *tabBarVC;
    spgARViewController *ARVC;
    spgGaugesViewController *gaugeVC;
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
    ARVC=[self.childViewControllers objectAtIndex:0];
    gaugeVC=[self.childViewControllers objectAtIndex:1];
    
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

//only change mode when connected
-(void)reportHorizontalLeftSwipe:(UIGestureRecognizer *)recognizer
{
    CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    if(currentState==CBPeripheralStateConnected)
    {
        [self switchViewMode:YES];
    }
}

//only change mode when connected
-(void)reportHorizontalRightSwipe:(UIGestureRecognizer *)recognizer
{
    CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    if(currentState==CBPeripheralStateConnected)
    {
        [self switchViewMode:NO];
    }
}

-(void)showGauge
{
    if(self.GaugeView && self.GaugeView.hidden)
    {
        self.GaugeView.hidden=NO;
        self.ARView.hidden=YES;
    }
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

#pragma - spgScooterPresentationDelegate

-(void)updateConnectionState:(BOOL) connected
{
    [self updateConnectedUIState];
    
    //if(self.ARView.hidden)
    {
        [gaugeVC updateConnectionState:connected];
    }
    //else
    {
        [ARVC updateConnectionState:connected];
    }
}

-(void)updateSpeed:(float) speed
{
    //if(self.ARView.hidden)
    {
        [gaugeVC updateSpeed:speed];
    }
    //else
    {
        [ARVC updateSpeed:speed];
    }
}

-(void)updateBattery:(float) battery
{
    //if(self.ARView.hidden)
    {
        [gaugeVC updateBattery:battery];
    }
    //else
    {
        [ARVC updateBattery:battery];
    }
}

-(void)modeChanged
{
    [self switchViewMode:YES];
}

-(void)cameraTriggered:(SBSCameraCommand)commandType
{
    [ARVC cameraTriggered:commandType];
    
    if(commandType==SBSCameraCommandTakePhoto||commandType==SBSCameraCommandStopRecordVideo)
    {
        UITabBarItem *momentsItem= self.tabBarController.tabBar.items[0];
        int count=[momentsItem.badgeValue intValue];
        momentsItem.badgeValue=[NSString stringWithFormat:@"%d", count+1];
    }
}

-(void)passwordCertified:(CBPeripheral *)peripheral result:(BOOL)correct
{
    [gaugeVC passwordCertified:peripheral result:correct];
}

#pragma - update connection UI

-(void) updateConnectedUIState
{
    CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    BOOL connected=currentState==CBPeripheralStateConnected;
    self.connectedImage.highlighted= connected;
}

@end
