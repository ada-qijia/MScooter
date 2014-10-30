//
//  spgTabBarViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgTabBarViewController.h"
#import "spgDashboardViewController.h"

static const NSInteger warningViewTag=8888;

@interface spgTabBarViewController ()

@property (strong,nonatomic) spgBLEService *bleService;

@end

@implementation spgTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate=self;
    self.bleService=[spgBLEService sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

//add top notification bar
-(void) setWarningBarHidden:(BOOL)hidden
{
    CGRect topFrame=CGRectMake(0, 0, 320, 40);
    UIView *warningView=[[UIView alloc] initWithFrame:topFrame];
    warningView.backgroundColor=[UIColor blackColor];
    warningView.transform=CGAffineTransformMakeTranslation(0, -40);
    warningView.tag=warningViewTag;
    
    UILabel *contentLabel=[[UILabel alloc] initWithFrame:topFrame];
    [contentLabel setTextColor:[UIColor redColor]];
    contentLabel.font=[UIFont fontWithName:@"System" size:14];
    contentLabel.textAlignment=NSTextAlignmentCenter;
    contentLabel.text=@"Connection failed!";
    [warningView addSubview:contentLabel];
    
    UIView *transitionView= self.view.subviews[0];
    [transitionView addSubview:warningView];
    
    CAKeyframeAnimation *fadeAnimation=[CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    fadeAnimation.keyTimes=[NSArray arrayWithObjects:0,0.15,0.85,1.0, nil];
    fadeAnimation.values=[NSArray arrayWithObjects:[NSNumber numberWithFloat:-40],[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:-40], nil];
    fadeAnimation.duration=3;
    fadeAnimation.delegate=self;
    
    [warningView.layer addAnimation:fadeAnimation forKey:@"notifyAnimation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (flag) {
        UIView *transitionView= self.view.subviews[0];
        UIView *warningView= [transitionView viewWithTag:warningViewTag];
        [warningView.layer removeAllAnimations];
        [warningView removeFromSuperview];
    }
}

#pragma -UITabBarControllerDelegate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    self.lastSelectedIndex=self.selectedIndex;
    return YES;
}

@end
