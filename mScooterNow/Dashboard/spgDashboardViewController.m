//
//  spgDashboardViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgDashboardViewController.h"
#import "WMGaugeView.h"
#import "spgGaugesViewController.h"
#import "spgScanViewController.h"
//#import "spgVideoCaptureViewController.h"
#import "spgCamViewController.h"

#define dashboardView [self.view viewWithTag:1]
#define ARView [self.view viewWithTag:2]

@interface spgDashboardViewController ()

@end

@implementation spgDashboardViewController
{
    spgCamViewController *videoCaptureVC;
    ARMode currentMode;
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
    
    [self initVideoCaptureVC];
    
    UISwipeGestureRecognizer *horizontalLeftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalLeftSwipe:)];
    horizontalLeftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:horizontalLeftSwipe];
    
    UISwipeGestureRecognizer *horizontalRightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalRightSwipe:)];
    horizontalRightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontalRightSwipe];
    
    if(self.bleService && self.peripheral)
    {
        self.bleService.peripheralDelegate=self;
        [self.bleService connectPeripheral:self.peripheral];
    }
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
    
    [videoCaptureVC stopVideoCapture];
    
    [UIApplication sharedApplication].statusBarHidden=NO;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    spgGaugesViewController *gaugesVC= self.childViewControllers[0];
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.contentView.frame=CGRectMake(0, 0, 568, 320);
        self.topControllerView.frame=CGRectMake(0, 0,44, 320);
        self.camButton.frame=CGRectMake(7, 10 ,32, 30);
        self.modesSwitchButton.frame=CGRectMake(7, 150, 32, 30);
        self.currentModeLabel.frame=CGRectMake(0, 135, 50, 21);
        self.ARModesView.frame=CGRectMake(0, 120 ,135, 44);
        self.modeButton.frame=CGRectMake(7, 279, 33, 30);
        
        [gaugesVC rotateLayout:NO];
    }
    else
    {
        self.contentView.frame=CGRectMake(0, 0, 320, 568);
        self.topControllerView.frame=CGRectMake(0, 0,320, 44);
        self.camButton.frame=CGRectMake(279, 7 ,32, 30);
        self.modesSwitchButton.frame=CGRectMake(110, 7, 32, 30);
        self.currentModeLabel.frame=CGRectMake(145, 12, 50, 21);
        self.ARModesView.frame=CGRectMake(145, 0 ,135, 44);
        self.modeButton.frame=CGRectMake(10, 7, 33, 30);
        
        [gaugesVC rotateLayout:YES];
    }
}

#pragma mark - gesture methods

-(void)reportHorizontalLeftSwipe:(UIGestureRecognizer *)recognizer
{
    [self switchMainView:YES];
}

-(void)reportHorizontalRightSwipe:(UIGestureRecognizer *)recognizer
{
    [self switchMainView:NO];
}

-(void)switchMainView:(BOOL)left
{
    UIView *currentView=dashboardView.hidden?ARView:dashboardView;
    UIView *nextView=dashboardView.hidden?dashboardView:ARView;
    
    //[UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{currentView.hidden=YES;nextView.hidden=NO;} completion:nil];
    //[UIView transitionFromView:currentView toView:nextView duration:1 options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionCurveEaseIn completion:nil];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype =left? kCATransitionFromRight:kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [nextView.layer addAnimation:transition forKey:nil];
    [currentView.layer addAnimation:transition forKey:nil];
    
    currentView.hidden=YES;
    nextView.hidden=NO;

    self.modeButton.hidden=nextView==ARView?NO:YES;
    self.camButton.hidden=self.modeButton.hidden;
  
    self.tabBarController.tabBar.hidden=nextView==ARView;
    self.powerButton.hidden=nextView==ARView;
    self.modeButton.hidden=!self.powerButton.hidden;
    self.modesSwitchButton.hidden=self.modeButton.hidden;
    self.currentModeLabel.hidden=self.modesSwitchButton.hidden;
}

#pragma mark - custom methods

-(void)initVideoCaptureVC
{
    UIViewController *gaugesVC= [self.childViewControllers objectAtIndex:0];
    for (UIViewController *vc in gaugesVC.childViewControllers) {
        if ([vc isKindOfClass:spgCamViewController.class])
        {
            videoCaptureVC=(spgCamViewController *)vc;
            break;
        }
    }
}

//colorful borders of dashboard gauge
-(void)SetDashboardCirclesHiden:(BOOL) hidden
{
    [self.view viewWithTag:31].hidden=hidden;
    [self.view viewWithTag:32].hidden=hidden;
    [self.view viewWithTag:33].hidden=hidden;
}

-(void)setWarningBarHidden:(BOOL) hidden
{
    self.warningView.hidden=hidden;
}

#pragma mark - spgBLEService delegate

-(void)centralManager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral
{
    [self setWarningBarHidden:YES];
    [self SetDashboardCirclesHiden:NO];
}

-(void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self setWarningBarHidden:NO];
    [self SetDashboardCirclesHiden:YES];
}

-(void)speedValueUpdated:(NSData *)speedData
{
    [self LogData:speedData ofCharacteristic:@"Speed"];
    NSInteger speedViewTag=dashboardView.hidden?41:34;
    
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
    
    WMGaugeView *speedView = (WMGaugeView *)[self.view viewWithTag:speedViewTag];
    [speedView setValue:realSpeed animated:YES duration:0.3];
    
    spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:0];
    gaugesVC.speedLabel.text=[NSString stringWithFormat:@"%02.f",realSpeed];
}

-(void)batteryValueUpdated:(NSData *)batteryData
{
    NSInteger batteryViewTag=dashboardView.hidden?42:35;
    [self LogData:batteryData ofCharacteristic:@"Battery"];
    
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
    
    WMGaugeView *batteryView = (WMGaugeView *)[self.view viewWithTag:batteryViewTag];
    //batteryView.value=rand()%(int)batteryView.maxValue;
    batteryView.value=realBattery;
    
    WMGaugeView *distanceView = (WMGaugeView *)[self.view viewWithTag:36];
    distanceView.value=batteryView.value;
}

-(void)cameraTriggered:(SBSCameraCommand) commandType
{
    if(!ARView.hidden)
    {
        switch (commandType) {
            case SBSCameraCommandTakePhoto:
                [videoCaptureVC snapStillImage];
                break;
            case SBSCameraCommandStartRecordVideo:
                [videoCaptureVC startVideoCapture];
                break;
            case SBSCameraCommandStopRecordVideo:
                [videoCaptureVC stopVideoCapture];
                break;
            default:
                break;
        }
    };
}

-(void)modeChanged
{
    if(!ARView.hidden)
    {
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
        //[self switchMode:nil];
    };
}

-(void)autoPoweredOff
{
    self.powerButton.selected=!self.powerButton.selected;
    //power on
    [self.bleService writePower:self.peripheral value:[self getData:247]];
}

-(void)powerCharacteristicFound
{
    NSLog(@"power on now");
    //power on 247
    [self.bleService writePower:self.peripheral value:[self getData:33]];
}

-(void)LogData:(NSData *)data ofCharacteristic:(NSString *)type
{
    NSMutableString *mutableString=[[NSMutableString alloc] init];
    Byte *bytes=(Byte *)data.bytes;
    for(int i=0;i<data.length;i++)
    {
        NSString *hex=[NSString stringWithFormat:@"%X", bytes[i]];
        [mutableString appendString:hex];
    }
    
    NSLog(@"%@: %@ \n",type, mutableString);
}

#pragma mark - UI interaction

- (IBAction)RetryClicked:(id)sender {
    spgScanViewController *root=(spgScanViewController *)self.presentingViewController;
    root.shouldRetry=YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)lightClicked:(UIButton *)sender {
    sender.selected=!sender.selected;
    if(sender.selected)//on
    {
        [self.bleService writePower:self.peripheral value:[self getData:251]];
    }
    else//off
    {
         [self.bleService writePower:self.peripheral value:[self getData:253]];
    }
}

- (IBAction)powerOff:(UIButton *)sender {
    [self.bleService writePower:self.peripheral value:[self getData:249]];
    //give ble receiver some time to handle the signal before disconnect.
    [self performSelector:@selector(RetryClicked:) withObject:nil afterDelay:1];
}

//between video and photo
- (IBAction)switchMode:(UIButton *)sender {
    self.modeButton.selected=!self.modeButton.selected;
    [videoCaptureVC switchMode:self.modeButton.selected];
}

- (IBAction)switchCam:(id)sender {
    [videoCaptureVC changeCamera];
}

- (IBAction)switchARMode:(UIButton *)sender {
    self.ARModesView.hidden=YES;
    self.currentModeLabel.hidden=NO;
    
     if([sender.titleLabel.text isEqual:@"AR Cool"])
    {
        [self gotoARMode:ARModeCool];
    }
    else if([sender.titleLabel.text isEqual:@"AR List"])
    {
        [self gotoARMode:ARModeList];
    }
    else
    {
        [self gotoARMode:ARModeNormal];
    }
}

- (IBAction)showARModes:(id)sender {
    self.currentModeLabel.hidden=YES;
    self.ARModesView.hidden=NO;
}

-(void)gotoARMode:(ARMode)toMode
{
    if(currentMode!=toMode)
    {
        currentMode=toMode;
        
        spgGaugesViewController *gaugesVC= [self.childViewControllers objectAtIndex:0];
        if(toMode==ARModeCool)
        {
            self.currentModeLabel.text=@"AR Cool";
            gaugesVC.ARInfoView.hidden=NO;
            gaugesVC.ARListView.hidden=YES;
        }
        else if(toMode==ARModeList)
        {
            self.currentModeLabel.text=@"AR List";
            gaugesVC.ARInfoView.hidden=YES;
            gaugesVC.ARListView.hidden=NO;
        }
        else
        {
            self.currentModeLabel.text=@"Normal";
            gaugesVC.ARInfoView.hidden=YES;
            gaugesVC.ARListView.hidden=YES;
        }
    }
}

#pragma mark - utilities

-(NSData *)getData:(Byte)value
{
    Byte bytes[]={value};
    NSData *data=[NSData dataWithBytes:bytes length:1];
    return data;
}
@end
