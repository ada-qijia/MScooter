//
//  spgDashboardViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgDashboardViewController.h"
#import "WMGaugeView.h"
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
    
    UISwipeGestureRecognizer *horizontalSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalSwipe:)];
    horizontalSwipe.direction=UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontalSwipe];
    
    if(self.bleService && self.peripheral)
    {
        self.bleService.peripheralDelegate=self;
        [self.bleService connectPeripheral:self.peripheral];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(self.bleService)
    {
        [self.bleService disConnectPeripheral:self.peripheral];
    }
    
    [videoCaptureVC stopVideoCapture];
}


#pragma mark - gesture methods

-(void)reportHorizontalSwipe:(UIGestureRecognizer *)recognizer
{
    //UIView *dashboardView=[self.view viewWithTag:1];
    //UIView *ARView=[self.view viewWithTag:2];
    /*
    dashboardView.hidden=!dashboardView.hidden;
    ARView.hidden=!dashboardView.hidden;
    self.camButtonsView.hidden=ARView.hidden;
     */
    UIView *currentView=dashboardView.hidden?ARView:dashboardView;
    UIView *nextView=dashboardView.hidden?dashboardView:ARView;
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{currentView.hidden=YES;nextView.hidden=NO;} completion:nil];
    
    //[UIView transitionFromView:currentView toView:nextView duration:1 options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionCurveEaseIn completion:nil];
    
    /*
    if(ARView.hidden)
    {
       [videoCaptureVC stopVideoCapture];
    }
    else
    {
       [videoCaptureVC startVideoCapture];
    }
     */
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

-(void)cameraTriggered
{
    if(!ARView.hidden)
    {
        [videoCaptureVC captureMedia:nil];
    };
}

-(void)modeChanged
{
    if(!ARView.hidden)
    {
        [videoCaptureVC switchMode:nil];
    };
}

-(void)powerCharacteristicFound
{
    NSLog(@"power on now");
    //power on
    [self.bleService writePower:self.peripheral value:[self getData:247]];
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

#pragma mark - utilities

-(NSData *)getData:(Byte)value
{
    Byte bytes[]={value};
    NSData *data=[NSData dataWithBytes:bytes length:1];
    return data;
}
@end
