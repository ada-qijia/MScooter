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

@interface spgGaugesViewController ()

@end

@implementation spgGaugesViewController

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
    spgBLEService *bleService=[spgBLEService sharedInstance];
    BOOL connected=bleService.peripheral.state==CBPeripheralStateConnected;
    [self setAddConnectUIState:(!connected)];
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
    // Dispose of any resources that can be recreated.
}

#pragma - update UI

- (IBAction)AddScooter:(UIButton *)sender {
    spgScanViewController *scanVC=[[spgScanViewController alloc] initWithNibName:@"spgScan" bundle:nil];
    [self presentViewController:scanVC animated:YES completion:nil];
}

- (IBAction)ConnectScooter:(UIButton *)sender {
    [[spgBLEService sharedInstance] connectPeripheral];
}

-(void)rotateLayout:(BOOL)portrait
{}

-(void)setGaugesEnabled:(BOOL)enabled
{
    //colorful circles
    [self.view viewWithTag:31].hidden=!enabled;
    [self.view viewWithTag:32].hidden=!enabled;
    [self.view viewWithTag:33].hidden=!enabled;
    
    [self setAddConnectUIState:enabled];
}

-(void)setBatteryLow:(BOOL)low
{
    NSString *imgName=low?@"batteryLowBg.png":@"batteryBg.png";
    self.batteryBgImage.image=[UIImage imageNamed:imgName];
}

-(void)setAddConnectUIState:(BOOL)enabled
{
    if(enabled)
    {
        BOOL isPersonal=[[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey] isEqualToString:kScenarioModePersonal];
        NSString *knownUUIDString=[spgMScooterUtilities getPreferenceWithKey:kMyPeripheralIDKey];
        BOOL passwordOn=[[spgMScooterUtilities getPreferenceWithKey:kPasswordOnKey] isEqualToString:@"YES"];
        
        //set peripheral
        if([spgBLEService sharedInstance].peripheral==nil)
        {
            if(isPersonal && knownUUIDString)//saved
            {
                NSUUID *knownUUID=[[NSUUID alloc] initWithUUIDString:knownUUIDString];
                NSArray *savedIdentifier=[NSArray arrayWithObjects:knownUUID, nil];
                NSArray *knownPeripherals= [[spgBLEService sharedInstance].centralManager retrievePeripheralsWithIdentifiers:savedIdentifier];
                if(knownPeripherals.count>0)
                {
                    [spgBLEService sharedInstance].peripheral=knownPeripherals[0];
                }
            }
        }
        
        if([spgBLEService sharedInstance].peripheral)//connect to old peripheral
        {
            self.AddButton.hidden=YES;
            self.ConnectButton.hidden=passwordOn?NO:YES;
            if(!passwordOn)
            {
                [[spgBLEService sharedInstance] connectPeripheral];
            }
        }
        else//need add
        {
            self.AddButton.hidden=NO;
            self.ConnectButton.hidden=YES;
        }
    }
    else
    {
        self.AddButton.hidden=YES;
        self.ConnectButton.hidden=YES;
    }
}

@end
