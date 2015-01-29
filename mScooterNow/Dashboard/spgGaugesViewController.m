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
    BOOL shouldPowerOn;
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
    NSNumber *num=[spgBLEService sharedInstance].isCertified;
    if(num)
    {
        BOOL isCertified=[num boolValue];
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
        {
            Byte mode=sender.selected?PowerOffCmd:PowerOnCmd;
            NSData *data=[spgMScooterUtilities getDataFromByte:mode];
            [[spgBLEService sharedInstance] writePower:data];
        }
    }
}

-(void)rotateLayout:(BOOL)portrait
{}

-(void)setGaugesColorful:(BOOL)enabled
{
    [self.view viewWithTag:31].hidden=!enabled;
    [self.view viewWithTag:32].hidden=!enabled;
    [self.view viewWithTag:33].hidden=!enabled;
}

-(void)setGaugesEnabled:(BOOL)enabled
{
    //colorful circles
    [self setGaugesColorful:enabled];
    
    if(!enabled)
    {
        [self.speedGaugeView setValue:0 animated:YES duration:0.3];
        self.BatteryLabel.text=@"-";
        //self.DistanceLabel.text=self.BatteryLabel.text;
    }
}

-(void)updateMileage:(int)mileage
{
    int kmDistance=mileage/1000;
    if(kmDistance>0)
    {
        self.DistanceLabel.text=[NSString stringWithFormat:@"%d",kmDistance];
        self.DistanceUnitLabel.text=@"km";
    }
    else
    {
        self.DistanceLabel.text=[NSString stringWithFormat:@"%d",mileage];
        self.DistanceUnitLabel.text=@" m";
    }
}

-(void)updatePowerState:(PowerState) state
{
    [self resetConnectionState];
}

//All the connect, certify, UI logic are here.
-(void)resetConnectionState
{
    spgTabBarViewController *tabBarVC=(spgTabBarViewController *)self.tabBarController;
    
    CBPeripheralState currentState= [spgBLEService sharedInstance].peripheral.state;
    NSNumber *scooterCertified=[spgBLEService sharedInstance].isCertified;
    
    if(currentState==CBPeripheralStateConnected)
    {
        if([scooterCertified boolValue])
        {
            [self setGaugesEnabled:YES];
            BOOL colorful=tabBarVC.currentPowerState==PowerOn||tabBarVC.currentPowerState==PowerAlwaysOn;
            [self setGaugesColorful:colorful];
        }
        else
        {
            [self setGaugesEnabled:NO];
        }
    }
    else if(currentState==CBPeripheralStateConnecting)//connecting
    {
        [self setGaugesEnabled:NO];
    }
    else//disconnected
    {
        [self setGaugesEnabled:NO];
    }
    
    //set power state
    NSLog(@"current state: %lu",tabBarVC.currentPowerState);
    self.PowerButton.hidden=currentState!=CBPeripheralStateConnected||scooterCertified==nil||tabBarVC.currentPowerState==PowerAlwaysOn||tabBarVC.currentPowerState==PowerStatUnDefined;
    //[self.PowerButton setEnabled:tabBarVC.currentPowerState!=PowerAlwaysOn];
    self.PowerButton.selected=tabBarVC.currentPowerState==PowerOn||tabBarVC.currentPowerState==PowerAlwaysOn;
    
}

-(void)breathAnimation:(UIView *)view
{
    view.alpha=0.2;
    [UIView animateWithDuration:1 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction) animations:^{view.alpha=1.0;} completion:nil];
}

#pragma - supported orientation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    /*
     self.view.frame=CGRectMake(0, 0, size.width, size.height);
     NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"spgGaugesLandscapeView" owner:self options:nil];
     UIView *myView = [nibContents objectAtIndex:0];
     myView.frame = self.view.frame;
     self.view=myView;*/
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
    self.BatteryLabel.text=[NSString stringWithFormat:@"%0.f", battery];
    //self.DistanceLabel.text=[NSString stringWithFormat:@"%0.f", battery/4];//25km, 100battery at most.
    
    NSString *imgName=battery<15?@"batteryLowBg.png":@"batteryBg.png";
    self.batteryBgImage.image=[UIImage imageNamed:imgName];
}

-(void)updateCertifyState:(BOOL)certified
{
    //send powerOn cmd
    if(certified && shouldPowerOn)
    {
        shouldPowerOn=NO;
        
        Byte mode=self.PowerButton.selected?PowerOffCmd:PowerOnCmd;
        NSData *data=[spgMScooterUtilities getDataFromByte:mode];
        [[spgBLEService sharedInstance] writePower:data];
    }
    
    [self resetConnectionState];
}

/*
 -(void)passwordCertified:(CBPeripheral *)peripheral result:(BOOL)correct
 {
 isCertifying=NO;
 
 if(correct)
 {
 if(peripheral==[spgBLEService sharedInstance].peripheral)
 {
 scooterCertified=YES;
 }
 
 
 //save peripheral UUID if success and in personal mode.
 BOOL isPersonal=[[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey] isEqualToString:kScenarioModePersonal];
 if(isPersonal)
 {
 [spgMScooterUtilities savePreferenceWithKey:kMyPeripheralIDKey value:[peripheral.identifier UUIDString]];
 }
 
 [self resetConnectionState];
 }
 else
 {
 //re-enter password
 }
 }*/

@end
