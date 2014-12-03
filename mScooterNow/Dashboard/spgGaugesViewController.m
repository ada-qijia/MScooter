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
    BOOL scooterCertified;
    BOOL isCertifying;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (IBAction)AddScooter:(UIButton *)sender {
    [spgBLEService sharedInstance].peripheral=nil;
    spgScanViewController *scanVC=[[spgScanViewController alloc] initWithNibName:@"spgScan" bundle:nil];
    [self presentViewController:scanVC animated:YES completion:nil];
}

- (IBAction)ConnectScooter:(UIButton *)sender {
    NSArray *buttons=[NSArray arrayWithObjects:@"CANCEL", @"OK",nil];
    spgAlertView *alert=[[spgAlertView alloc] initPasscodeWithTitle:@"Enter Your Passcode" buttons:buttons correctPasscode:@"8888" afterDismiss:^(NSString* passcode, int buttonIndex) {
        if(buttonIndex==1)
        {
            [self certifyScooter];
        }
    }];
    [[spgAlertViewManager sharedAlertViewManager] show:alert];
}

-(void)rotateLayout:(BOOL)portrait
{}

-(void)setGaugesEnabled:(BOOL)enabled
{
    //colorful circles
    [self.view viewWithTag:31].hidden=!enabled;
    [self.view viewWithTag:32].hidden=!enabled;
    [self.view viewWithTag:33].hidden=!enabled;
    
    if(!enabled)
    {
        [self.speedGaugeView setValue:0 animated:YES duration:0.3];
        self.BatteryLabel.text=@"0";
        self.DistanceLabel.text=self.BatteryLabel.text;
    }
}

//All the connect, certify, UI logic are here.
-(void)resetConnectionState
{
    CBPeripheralState currentState= [spgBLEService sharedInstance].peripheral.state;
    BOOL passwordOn=[[spgMScooterUtilities getPreferenceWithKey:kPasswordOnKey] isEqualToString:@"YES"];
    if(currentState==CBPeripheralStateConnected)
    {
        if(!passwordOn)
        {
            if(scooterCertified)
            {
                [self setGaugesEnabled:YES];
                self.AddButton.hidden=YES;
                self.ConnectButton.hidden=YES;
            }
            else
            {
                if(!isCertifying)
                {
                    [self certifyScooter];
                }
                [self setGaugesEnabled:NO];
                self.AddButton.hidden=YES;
                self.ConnectButton.hidden=YES;
            }
        }
        //auto certify
        else if([spgMScooterUtilities getPreferenceWithKey:kAutoReconnectUUIDKey]&& (!scooterCertified))
        {
            [self certifyScooter];
        }
        else
        {
            if(scooterCertified)
            {
                [self setGaugesEnabled:YES];
                self.AddButton.hidden=YES;
                self.ConnectButton.hidden=YES;
            }
            else
            {
                self.ConnectButton.hidden=isCertifying;
                [self setGaugesEnabled:NO];
                self.AddButton.hidden=YES;
            }
        }
    }
    else if(currentState==CBPeripheralStateConnecting)//connecting
    {
        [self setGaugesEnabled:NO];
        self.AddButton.hidden=YES;
        self.ConnectButton.hidden=YES;
    }
    else//disconnected
    {
        [self setGaugesEnabled:NO];
        
        scooterCertified=NO;
        
        BOOL isPersonal=[[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey] isEqualToString:kScenarioModePersonal];
        NSString *knownUUIDString=[spgMScooterUtilities getPreferenceWithKey:kMyPeripheralIDKey];
        
        //auto reconnect
        NSString * autoReconnectUUID=[spgMScooterUtilities getPreferenceWithKey:kAutoReconnectUUIDKey];
        
        NSString * usefulUUID=nil;
        //set saved peripheral
        if([spgBLEService sharedInstance].peripheral==nil)
        {
            if(autoReconnectUUID)
            {
                usefulUUID=autoReconnectUUID;
            }
            else if(isPersonal && knownUUIDString)//saved
            {
                usefulUUID=knownUUIDString;
            }
        }
        
        if(usefulUUID)
        {
            NSUUID *knownUUID=[[NSUUID alloc] initWithUUIDString:usefulUUID];
            NSArray *savedIdentifier=[NSArray arrayWithObjects:knownUUID, nil];
            NSArray *knownPeripherals= [[spgBLEService sharedInstance].centralManager retrievePeripheralsWithIdentifiers:savedIdentifier];
            if(knownPeripherals.count>0)
            {
                [spgBLEService sharedInstance].peripheral=knownPeripherals[0];
            }
        }
        
        if([spgBLEService sharedInstance].peripheral)//connect to peripheral
        {
            self.AddButton.hidden=YES;
            [[spgBLEService sharedInstance] connectPeripheral];
        }
        else//need add
        {
            self.AddButton.hidden=NO;
            self.ConnectButton.hidden=YES;
        }
    }
}

#pragma - password alert

-(void)certifyScooter
{
    isCertifying=YES;
    
    NSString *currentPin=@"8888";
    Byte byte0=[[currentPin substringToIndex:2] intValue];
    Byte byte1=[[currentPin substringFromIndex:2] intValue];
    Byte array[]={byte0,byte1};
    NSData *pinData=[NSData dataWithBytes:array length:2];
    
    
    //write may fail because characteristic not found.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL writeSuccess=[[spgBLEService sharedInstance] writePassword:pinData];
        while (!writeSuccess) {
            [NSThread sleepForTimeInterval:1];
            writeSuccess= [[spgBLEService sharedInstance] writePassword:pinData];
        }
    });
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
    self.DistanceLabel.text=self.BatteryLabel.text;
    
    NSString *imgName=battery<15?@"batteryLowBg.png":@"batteryBg.png";
    self.batteryBgImage.image=[UIImage imageNamed:imgName];
}

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
}

@end
