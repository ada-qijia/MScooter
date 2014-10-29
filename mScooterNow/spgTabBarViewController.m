//
//  spgTabBarViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgTabBarViewController.h"
#import "spgDashboardViewController.h"

@interface spgTabBarViewController ()

@property (strong,nonatomic) spgBLEService *bleService;

@end

@implementation spgTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bleService=[spgBLEService sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden=YES;
    
    self.bleService.peripheralDelegate=self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

     if(self.bleService)
     {
         self.bleService.peripheralDelegate=nil;
         [self.bleService disConnectPeripheral];
     }
    
    [UIApplication sharedApplication].statusBarHidden=NO;
}

#pragma - supported orientation

//set only the AR view support landscape orientation.
-(NSUInteger)supportedInterfaceOrientations
{
    if(self.selectedIndex==1)
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - spgBLEService delegate

-(void)centralManager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral
{
    id<spgScooterPresentationDelegate> vc= (id<spgScooterPresentationDelegate>)self.selectedViewController;
    if([vc respondsToSelector:@selector(updateConnectionState:)])
    {
        [vc updateConnectionState:YES];
    }

    [self setWarningBarHidden:YES];
}

-(void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    id<spgScooterPresentationDelegate> vc= (id<spgScooterPresentationDelegate>)self.selectedViewController;
    if([vc respondsToSelector:@selector(updateConnectionState:)])
    {
        [vc updateConnectionState:NO];
    }
 
    [self setWarningBarHidden:NO];
}

-(void)speedValueUpdated:(NSData *)speedData
{
    [spgMScooterUtilities LogData:speedData title:@"Speed"];
    
    float realSpeed=0;
    int16_t i=0;
    [speedData getBytes:&i length:sizeof(i)];
    
    if(i>245)
    {
        realSpeed=27;
    }
    else if(i>=226 && i<=245)
    {
        realSpeed=25;
    }
    else if(i>=201&&i<=225)
    {
        realSpeed=23;
    }
    else if(i>=180&&i<=200)
    {
        realSpeed=20;
    }
    else if(i>=160&&i<=179)
    {
        realSpeed=17;
    }
    else if(i>=140&&i<=159)
    {
        realSpeed=15;
    }
    else if(i>120&&i<140)
    {
        realSpeed=5*(i-115)/15.0+10;
    }
    else if(i>=110&&i<=120)
    {
        realSpeed=10;
    }
    else if(i>60&&i<110)
    {
        realSpeed=5*(i-55)/60.0+5;
    }
    else if(i>=50&&i<=60)
    {
        realSpeed=5;
    }
    else if(i>20 &&i<50)
    {
        realSpeed=4*(i-15)/40.0+1;
    }
    else if(i>=10&&i<=20)
    {
        realSpeed=1;
    }
    
    //update speed
    id<spgScooterPresentationDelegate> vc= (id<spgScooterPresentationDelegate>)self.selectedViewController;
    if([vc respondsToSelector:@selector(updateSpeed:)])
    {
        [vc updateSpeed:realSpeed];
    }
}

-(void)batteryValueUpdated:(NSData *)batteryData
{
    [spgMScooterUtilities LogData:batteryData title:@"Battery"];
    
    float realBattery=[spgMScooterUtilities castBatteryToPercent:batteryData];
    
    //update battery
    id<spgScooterPresentationDelegate> vc= (id<spgScooterPresentationDelegate>)self.selectedViewController;
    if([vc respondsToSelector:@selector(updateBattery:)])
    {
        [vc updateBattery:realBattery];
    }
}

-(void)cameraTriggered:(SBSCameraCommand) commandType
{
    id<spgScooterPresentationDelegate> vc= (id<spgScooterPresentationDelegate>)self.selectedViewController;
    if([vc respondsToSelector:@selector(cameraTriggered:)])
    {
        [vc cameraTriggered:commandType];
    }
}

-(void)modeChanged
{
    id<spgScooterPresentationDelegate> vc= (id<spgScooterPresentationDelegate>)self.selectedViewController;
    if([vc respondsToSelector:@selector(modeChanged)])
    {
        [vc modeChanged];
    }
}

#pragma - UI update

-(void) setWarningBarHidden:(BOOL)hidden
{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                               message:nil
                               delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reconnect",nil];
    [alert show];
}
@end
