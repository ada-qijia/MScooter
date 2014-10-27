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

@end

@implementation spgTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.bleService && self.peripheral)
    {
        self.bleService.peripheralDelegate=self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden=YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

     if(self.bleService)
     {
     [self.bleService disConnectPeripheral:self.peripheral];
     }
    
    [UIApplication sharedApplication].statusBarHidden=NO;
}

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
    /*
    [self setWarningBarHidden:YES];
    [self SetDashboardCirclesHiden:NO];
     */
}

-(void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    /*
    [self setWarningBarHidden:NO];
    [self SetDashboardCirclesHiden:YES];
     */
}

-(void)speedValueUpdated:(NSData *)speedData
{
    [spgMScooterUtilities LogData:speedData title:@"Speed: %@ /n"];
    
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
    if([self.selectedViewController respondsToSelector:@selector(updateSpeed:)])
    {
    }
}

-(void)batteryValueUpdated:(NSData *)batteryData
{
     [spgMScooterUtilities LogData:batteryData title:@"Battery: %@ /n"];
    
    int16_t i=0;
    [batteryData getBytes:&i length:sizeof(i)];
    float realV=i/511.0*3.2*16;//voltage
    float realBattery=0;
    if(realV>=42)
    {
        realBattery=100;
    }
    else if(realV<=30)
    {
        realBattery=5;
    }
    else
    {
        realBattery=(realV-30)*95/12.0+5;
    }
    
    //update battery
}

-(void)cameraTriggered:(SBSCameraCommand) commandType
{
    if(self.selectedIndex==1)
    {
        switch (commandType) {
                /*
            case SBSCameraCommandTakePhoto:
                self.modeButton.selected=YES;
                [videoCaptureVC snapStillImage];
                break;
            case SBSCameraCommandStartRecordVideo:
                self.modeButton.selected=NO;
                [videoCaptureVC startVideoCapture];
                break;
            case SBSCameraCommandStopRecordVideo:
                self.modeButton.selected=NO;
                [videoCaptureVC stopVideoCapture];
                break;
            default:
                break;
                 */
        }
    };
}

-(void)modeChanged
{
    if(self.selectedIndex==1)
    {
        /*
        ARMode toMode=ARModeCool;
        if(currentMode==ARModeCool)
        {
            toMode=ARModeList;
        }
        else if(currentMode==ARModeList)
        {
            toMode=ARModeNormal;
        }
        
        [self gotoARMode:toMode];
         */
    };
}

/*
-(void)powerCharacteristicFound
{
    NSLog(@"power on now");
    //power on 247
    //[self.bleService writePower:self.peripheral value:[self getData:33]];
}
 */

@end
