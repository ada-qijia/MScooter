//
//  spgGaugesViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgGaugesViewController.h"
#import "spgScanViewController.h"
#import "spgBLEService.h"
#import "spgAlertViewManager.h"

@interface spgGaugesViewController ()

@end

@implementation spgGaugesViewController
{
    BOOL isChangingPowerState;//should react to battery update to reflect battery state
    spgTabBarViewController *tabBarVC;
    BOOL shouldUpdateData;
    
    float lastBattery;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self resetConnectionState];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(tabBarVC==nil)
    {
        tabBarVC=(spgTabBarViewController *)self.parentViewController.parentViewController;
    }
    
    [self resetConnectionState];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGradient.jpg"]];
    
    self.speedGaugeView.unitOfMeasurementFont=[UIFont boldSystemFontOfSize:0.07];
    self.speedGaugeView.unitOfMeasurement=@"km/h";
    self.speedGaugeView.showUnitOfMeasurement=YES;
    self.speedGaugeView.minValue=0.0;
    self.speedGaugeView.maxValue = 40.0;
    self.speedGaugeView.scaleDivisions = 8;
    self.speedGaugeView.scaleSubdivisions = 5;
    self.speedGaugeView.scaleStartAngle = 45;
    self.speedGaugeView.scaleEndAngle = 315;
    self.speedGaugeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    self.speedGaugeView.showScaleShadow = YES;
    self.speedGaugeView.scaleFont =[UIFont boldSystemFontOfSize:0.05];// [UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    self.speedGaugeView.scalesubdivisionsAligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.speedGaugeView.scaleSubdivisionsWidth = 0.002;
    self.speedGaugeView.scaleSubdivisionsLength = 0.03;
    self.speedGaugeView.scaleDivisionsWidth = 0.007;
    self.speedGaugeView.scaleDivisionsLength = 0.05;
    self.speedGaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    self.speedGaugeView.needleWidth = 0.012;
    self.speedGaugeView.needleHeight = 0.4;
    self.speedGaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
    self.speedGaugeView.needleScrewRadius = 0.05;
    self.speedGaugeView.showScale=YES;
    self.speedGaugeView.scalePosition=0.05;
    self.speedGaugeView.scaleDivisionColor=[UIColor whiteColor];
    self.speedGaugeView.scaleSubDivisionColor=[UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma - update UI

- (IBAction)ChangePowerState:(UIButton *)sender {
    /*spgTabBarViewController *tabBarVC=(spgTabBarViewController *)self.tabBarController;
     if(tabBarVC.currentBatteryState==BatteryStateOff)
     {
     NSArray *buttons=[NSArray arrayWithObjects:@"OK", nil];
     spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:@"Please turn on the scooter battery first and try again." buttons:buttons afterDismiss:nil];
     [[spgAlertViewManager sharedAlertViewManager] show:alert];
     }
     else*/
    NSNumber *num=[spgBLEService sharedInstance].isCertified;
    if([num boolValue]==YES)
    {
        /* BOOL isCertified=[num boolValue];
         if(!isCertified)
         {
         
         spgPinView *alert=[[spgPinView alloc] initWithPin:@"9517" afterDismiss:^(NSString *passcode, int buttonIndex) {
         if(buttonIndex==1)
         {
         shouldPowerOn=YES;
         
         Byte array[]={0x95, 0x17};
         NSData *pinData=[NSData dataWithBytes:array length:2];
         [[spgBLEService sharedInstance] writePassword:pinData];
         }
         }];
         
         [[spgAlertViewManager sharedAlertViewManager] show:alert];
         }
         else
         
         {*/
        
        /*if(tabBarVC.currentBatteryState==BatteryStateOff)// && (tabBarVC.currentPowerState==PowerOn))
         {
         [self showBatteryAlert];
         }
         else
         {*/
        Byte mode=tabBarVC.currentPowerState==PowerOn?PowerOffCmd:PowerOnCmd;
        NSData *data=[spgMScooterUtilities getDataFromByte:mode];
        [[spgBLEService sharedInstance] writePower:data];
        
        isChangingPowerState=mode==PowerOnCmd;
        // }
        
        //shouldPowerOn=tabBarVC.currentBatteryState==BatteryStateOn?NO:YES;
        
        /*
         //reset battery state
         spgTabBarViewController *tabBarVC=(spgTabBarViewController *)self.tabBarController;
         tabBarVC.currentBatteryState=BatteryStateWaitUpdate;*/
        //}
    }
}

-(void)setGaugesEnabled:(BOOL)enabled
{
    [self setGaugesEnabled:enabled colorful:enabled];
}

-(void)setGaugesEnabled:(BOOL)enabled colorful:(BOOL)colorful
{
    //colorful circles
    [self.view viewWithTag:31].hidden=!colorful;
    [self.view viewWithTag:32].hidden=!colorful;
    [self.view viewWithTag:33].hidden=!colorful;
    
    
    if(!enabled)
    {
        [self.speedGaugeView setValue:0 animated:YES duration:0.3];
        //self.BatteryLabel.text=@"-";
        //self.DistanceLabel.text=self.BatteryLabel.text;
    }
}

-(void)updateMileage:(int)mileage
{
    float kmDistance=mileage/1000.0;
    self.DistanceLabel.text=[NSString stringWithFormat:@"%0.2f",kmDistance];
}

-(void)updatePowerState:(PowerState) state
{
    [self resetConnectionState];
    
    //isChangingPowerState=state==PowerOn||state==PowerAlwaysOn;
}

-(void)batteryStateChanged:(BatteryState)newState
{
    if(tabBarVC.currentPowerState==PowerOn||tabBarVC.currentPowerState==PowerAlwaysOn)
    {
        [self resetConnectionState];
    }
    
    [self showBatteryAlert];
}

-(void)showBatteryAlert
{
    if(tabBarVC.currentBatteryState==BatteryStateOff && isChangingPowerState)// && (tabBarVC.currentPowerState==PowerOn))
    {
        NSArray *buttons=[NSArray arrayWithObjects:@"OK", nil];
        spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:@"Please turn on the scooter battery first and try again." buttons:buttons afterDismiss:nil];
        [[spgAlertViewManager sharedAlertViewManager] show:alert];
    }
    
    isChangingPowerState=NO;
}

//All the connect, certify, UI logic are here.
-(void)resetConnectionState
{
    //CBPeripheralState currentState= [spgBLEService sharedInstance].peripheral.state;
    NSNumber *scooterCertified=[spgBLEService sharedInstance].isCertified;
    
    /*
     if(tabBarVC.currentBatteryState !=BatteryStateOn && (tabBarVC.currentPowerState==PowerOn))
     {
     [self setGaugesEnabled:NO colorful:NO];
     }
     else
     {
     if(currentState==CBPeripheralStateConnected)
     {
     if([scooterCertified boolValue])
     {
     BOOL colorful=tabBarVC.currentPowerState==PowerOn||tabBarVC.currentPowerState==PowerAlwaysOn;
     [self setGaugesEnabled:YES colorful:colorful];
     }
     else
     {
     [self setGaugesEnabled:NO colorful:NO];
     }
     }
     else if(currentState==CBPeripheralStateConnecting)//connecting
     {
     [self setGaugesEnabled:NO colorful:NO];
     }
     else//disconnected
     {
     [self setGaugesEnabled:NO colorful:NO];
     }
     }
     
     //set power state
     NSLog(@"current state: %lu",tabBarVC.currentPowerState);
     self.PowerButton.hidden=currentState!=CBPeripheralStateConnected||[scooterCertified boolValue]!=YES||(tabBarVC.currentPowerState==PowerAlwaysOn && [scooterCertified boolValue])||tabBarVC.currentPowerState==PowerStatUnDefined;
     //[self.PowerButton setEnabled:tabBarVC.currentPowerState!=PowerAlwaysOn];
     self.PowerButton.selected=tabBarVC.currentPowerState==PowerOn||tabBarVC.currentPowerState==PowerAlwaysOn;*/
    
    
    
    
    //show gauge
    if((tabBarVC.currentPowerState==PowerAlwaysOn||tabBarVC.currentPowerState==PowerOn) && [scooterCertified boolValue]==YES)
    {
        BOOL isColorful=tabBarVC.currentBatteryState!=BatteryStateOff;
        [self setGaugesEnabled:YES colorful:isColorful];
    }
    else
    {
        [self setGaugesEnabled:NO colorful:NO];
    }
    
    //power button state
    if((tabBarVC.currentPowerState==PowerOff||tabBarVC.currentPowerState==PowerOn) && [scooterCertified boolValue]==YES)
    {
        self.PowerButton.hidden=NO;
        self.PowerButton.selected=tabBarVC.currentPowerState==PowerOn||tabBarVC.currentPowerState==PowerAlwaysOn;
    }
    else
    {
        self.PowerButton.hidden=YES;
    }
    
    /*
     //whether auto update data
     if((tabBarVC.currentPowerState==PowerOff||tabBarVC.currentPowerState==PowerOn) && [scooterCertified boolValue]==YES &&tabBarVC.currentBatteryState==BatteryStateOn)
     {
     shouldUpdateData=YES;
     }
     else if((tabBarVC.currentPowerState==PowerOff||tabBarVC.currentBatteryState==BatteryStateOff) && [scooterCertified boolValue]==YES)
     {
     shouldUpdateData=NO;
     }
     else
     {
     //reset data
     }*/
}

-(void)breathAnimation:(UIView *)view
{
    view.alpha=0.2;
    [UIView animateWithDuration:1 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction) animations:^{view.alpha=1.0;} completion:nil];
}

#pragma - supported orientation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSString *bgImgName=size.width<size.height?@"bgGradient.jpg":@"bgGradientL.jpg";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:bgImgName]];
    
    NSString *batteryBgImgName=size.width<size.height?@"batteryBg.png":@"batteryBgL.png";
    self.batteryBgImage.image=[UIImage imageNamed:batteryBgImgName];
    
    if(size.width<size.height)
    {
        self.SpeedView.frame=CGRectMake(20, 60, 285, 285);
        self.BatteryView.frame=CGRectMake(32, 365, 104, 104);
        self.RangeView.frame=CGRectMake(184, 365, 104, 104);
        self.batteryBgImage.frame=CGRectMake(20, 353, 280, 128);
    }
    else
    {
        self.SpeedView.frame=CGRectMake(60, 20, 285, 285);
        self.BatteryView.frame=CGRectMake(365, 184, 104, 104);
        self.RangeView.frame=CGRectMake(365, 32, 104, 104);
        self.batteryBgImage.frame=CGRectMake(353, 20, 128, 280);
    }
}

#pragma - spgScooterPresentationDelegate

-(void)updateConnectionState:(BOOL) connected
{
    [self resetConnectionState];
}

-(void)updateSpeed:(float)speed
{
    [self.speedGaugeView setValue:speed animated:YES duration:0.3];
}

-(void)updateBattery:(float)battery
{
    int intBattery=(int)((battery+2.5)/5);
    self.BatteryLabel.text=[NSString stringWithFormat:@"%d", intBattery*5];
}

-(void)updateCertifyState:(BOOL)certified
{
    [self resetConnectionState];
}

@end
