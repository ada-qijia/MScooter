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
#import "spgAlertViewManager.h"
#import "spgLoginViewController.h"

@interface spgDashboardViewController ()

@property (strong,nonatomic) spgBLEService *bleService;

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
    tabBarVC=(spgTabBarViewController *)self.parentViewController;
    tabBarVC.scooterPresentationDelegate=self;

    /*
    //update orientation
    CGSize parentSize=tabBarVC.view.frame.size;
    if(parentSize.width>0 && self.view.frame.size.width!=parentSize.width)
    {
        self.view.frame=CGRectMake(0, 0, parentSize.width, parentSize.height);
        [self viewWillTransitionToSize:parentSize withTransitionCoordinator:nil];
    }
    
    [super viewWillAppear:animated];
    [self updateConnectedUIState];
     */
    
    //auto connect
    if([spgBLEService sharedInstance].centralManager==nil)
    {
        self.bleService=[[spgBLEService sharedInstance] initWithDelegates:self peripheralDelegate:tabBarVC];
    }
    else if([spgBLEService sharedInstance].peripheral.state==CBPeripheralStateDisconnected)
    {
        [[spgBLEService sharedInstance] connectPeripheral];
    }
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

#pragma - supported orientation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if(size.width>size.height)
    {
        self.topControllerView.frame=CGRectMake(0, 0, 40, size.height);
        self.camSwitchButton.frame=CGRectMake(7, 280, 32, 30);
        self.connectAnimationView.frame=CGRectMake(5, 15, 25, 25);
        self.IdentifyPhoneButton.frame=CGRectMake(0, 5, 40, 40);
        self.scooterNameLabel.frame=CGRectMake(12, 53, 21, 214);
    }
    else
    {
        self.topControllerView.frame=CGRectMake(0, 0, size.width, 40);
        self.camSwitchButton.frame=CGRectMake(10, 7, 32, 30);
        self.connectAnimationView.frame=CGRectMake(282, 5, 25, 25);
        self.IdentifyPhoneButton.frame=CGRectMake(275, 0, 40, 40);
        self.scooterNameLabel.frame=CGRectMake(53, 12, 214, 21);
    }
    self.noSignalImage.frame=self.connectAnimationView.frame;
    self.IdentifiedImage.frame=self.connectAnimationView.frame;
    
    
    self.ARView.frame=self.view.frame;
    self.GaugeView.frame=self.view.frame;
    
   [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - gesture methods

//change mode when connected or user is not in GaugeView
-(void)reportHorizontalLeftSwipe:(UIGestureRecognizer *)recognizer
{
    //CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    //if(currentState==CBPeripheralStateConnected||self.GaugeView.hidden)
    if([[spgBLEService sharedInstance].isCertified boolValue]==YES||self.GaugeView.hidden)
    {
        [self switchViewMode:YES];
    }
}

//change mode when connected or user is not in GaugeView
-(void)reportHorizontalRightSwipe:(UIGestureRecognizer *)recognizer
{
    /*
     CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
     if(currentState==CBPeripheralStateConnected||self.GaugeView.hidden)*/
    if([[spgBLEService sharedInstance].isCertified boolValue]==YES||self.GaugeView.hidden)
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
        self.camSwitchButton.hidden=self.ARView.hidden;
    }
}

-(void)switchViewMode:(BOOL) next
{
    int modeCount=5;
    DashboardMode toMode=next?(currentMode+1)%modeCount:(currentMode-1+modeCount)%modeCount;
    
    UIView *currentView;
    UIView *nextView;
    
    BOOL isBothARMode= currentMode!=Gauge && toMode!=Gauge;
    if(isBothARMode)
    {
        currentView=[self getViewOfARMode:currentMode];
        nextView=[self getViewOfARMode:toMode];
    }
    else
    {
        currentView=currentMode==Gauge?self.GaugeView:self.ARView;
        nextView =toMode==Gauge?self.GaugeView:self.ARView;
    }
    
    CATransition *transition = [self transitionOfMode:currentMode];
    transition.subtype = next? kCATransitionFromRight:kCATransitionFromLeft;
    [currentView.layer addAnimation:transition forKey:nil];
    
    CATransition *nextTransition = [self transitionOfMode:toMode];
    nextTransition.subtype = next? kCATransitionFromRight:kCATransitionFromLeft;
    [nextView.layer addAnimation:nextTransition forKey:nil];
    
    [[self getViewOfARMode:currentMode] setHidden:YES];
    [[self getViewOfARMode:toMode] setHidden:NO];
    currentView.hidden=YES;
    nextView.hidden=NO;
    
    currentMode=toMode;
    self.camSwitchButton.hidden=self.ARView.hidden;
}

-(CATransition *) transitionOfMode:(DashboardMode) mode
{
    CATransition *transition=[CATransition animation];
    transition.duration = 0.5;
    transition.type =mode==ARModeMap? kCATransitionFade:kCATransitionPush;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    return transition;
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
    
    [gaugeVC updateConnectionState:connected];
    [ARVC updateConnectionState:connected];
    
    //auto reconnect
    if(!connected)
    {
        /*
         if([spgBLEService sharedInstance].peripheral)
         {
         [[spgBLEService sharedInstance] connectPeripheral];
         }
         else*/
        {
            [self startScan];
        }
    }
    
}

-(void)updateSpeed:(float) speed
{
    [gaugeVC updateSpeed:speed];
    [ARVC updateSpeed:speed];
}

-(void)updateBattery:(float) battery
{
    [gaugeVC updateBattery:battery];
    [ARVC updateBattery:battery];
}

-(void)updateMileage:(int)mileage
{
    [gaugeVC updateMileage:mileage];
    
    //test
    UILabel *mileageLabel=(UILabel *)[self.view viewWithTag:222];
    mileageLabel.text=[NSString stringWithFormat:@"%d", mileage];
}

-(void)modeChanged
{
    if([[spgBLEService sharedInstance].isCertified boolValue]==YES||self.GaugeView.hidden)
    {
        [self switchViewMode:YES];
    }
}

-(void)cameraTriggered:(SBSCameraCommand)commandType
{
    [ARVC cameraTriggered:commandType];
    
    if(commandType==SBSCameraCommandTakePhoto||commandType==SBSCameraCommandStopRecordVideo)
    {
        int count=[tabBarVC.momentsBadge.text intValue];
        [tabBarVC setBadge:[NSString stringWithFormat:@"%d", count+1]];
    }
}

-(void)updateCertifyState:(BOOL)certified
{
    self.connectAnimationView.hidden=certified;
    self.IdentifyPhoneButton.hidden=certified;

    if(!certified)
    {
        [self twinkleAnimation];
    }
    
    self.IdentifiedImage.hidden=!certified;
    
    [gaugeVC updateCertifyState:certified];
    
    //test
    UILabel *label=(UILabel *)[self.view viewWithTag:333];
    label.text=certified?@"YES":@"NO";
}

-(void)powerStateReturned:(CBPeripheral *)peripheral result:(PowerState)currentState
{
    [gaugeVC updatePowerState:currentState];
    
    //test
    UILabel *label=(UILabel *)[self.view viewWithTag:444];
    label.text=[NSString stringWithFormat:@"%lu",currentState];
}

-(void)batteryStateChanged:(BatteryState)newState
{
    [gaugeVC batteryStateChanged:newState];
}

#pragma - spgBLEServiceDiscoverPeripheralsDelegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *message=nil;
    spgAlertViewBlock afterDismissBlock=nil;
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self startScan];
            break;
        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStateUnauthorized:
            message=central.state==CBCentralManagerStatePoweredOff? @"Please turn on Bluetooth to allow ScooterNow to connect to accessories.":@"Please make sure ScooterNow is authorized to use Bluetooth low energy.";
            [self CleanState];
            break;
        case CBCentralManagerStateUnsupported:
            message=@"This platform does not support Bluetooth low energy.";
            break;
        default:
            message=@"ScooterNow can not connect to accessories now.";
            break;
    }
    
    if(message!=nil)
    {
        NSArray *buttons=[NSArray arrayWithObjects:@"OK", nil];
        spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:message buttons:buttons afterDismiss:afterDismissBlock];
        [[spgAlertViewManager sharedAlertViewManager] show:alert];
    }
    
}

-(void)CleanState
{
    [spgBLEService sharedInstance].isCertified=nil;
    [self updateConnectionState:false];
}

//connect scooter once found one & stop scan.
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //connect
    self.bleService.peripheral=peripheral;
    [self.bleService stopScan];
    [self.bleService connectPeripheral];
}

//if has known scooter, use it.
-(void)startScan
{
    //start scan
    if(self.bleService.centralManager.state==CBCentralManagerStatePoweredOn)
    {
        /*
         NSString *knownUUIDString=[spgMScooterUtilities getPreferenceWithKey:kMyPeripheralIDKey];
         
         //find known peripheral
         if(knownUUIDString)
         {
         NSUUID *knownUUID=[[NSUUID alloc] initWithUUIDString:knownUUIDString];
         NSArray *savedIdentifier=[NSArray arrayWithObjects:knownUUID, nil];
         NSArray *knownPeripherals= [self.bleService.centralManager retrievePeripheralsWithIdentifiers:savedIdentifier];
         if(knownPeripherals.count>0)
         {
         //connect and update UI
         self.bleService.peripheral=knownPeripherals[0];
         [self.bleService connectPeripheral];
         }
         else
         {
         [self.bleService startScan];
         }
         }
         else*/
        {
            [self.bleService startScan];
        }
    }
}

#pragma - update connection UI

-(void) updateConnectedUIState
{
    CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    BOOL connected=currentState==CBPeripheralStateConnected;
    
    self.scooterNameLabel.text= [[spgBLEService sharedInstance] peripheral].name;
    
    
    NSNumber *isCertified= [spgBLEService sharedInstance].isCertified;
    
    BOOL showAnimation= connected && isCertified!=nil && [isCertified boolValue]==NO;
    self.connectAnimationView.hidden=!showAnimation;
    self.IdentifyPhoneButton.hidden=self.connectAnimationView.hidden;
    self.IdentifiedImage.hidden=[isCertified boolValue]!=YES;
}

- (IBAction)twinkleAnimation
{
    NSNumber *one=[NSNumber numberWithFloat:1];
    NSNumber *zero=[NSNumber numberWithFloat:0];
    NSArray *value1=[NSArray arrayWithObjects:zero,one,one,one,one, nil];
    NSArray *value2=[NSArray arrayWithObjects:zero,zero,one,one,one, nil];
    NSArray *value3=[NSArray arrayWithObjects:zero,zero,zero,one,one, nil];
    NSArray *value4=[NSArray arrayWithObjects:zero,zero,zero,zero,one, nil];
    
    NSArray *values=[NSArray arrayWithObjects:value1,value2,value3,value4, nil];
    
    for(int i=1;i<=4;i++)
    {
        UIImageView *imgView=(UIImageView *)[self.connectAnimationView viewWithTag:i];
        CAKeyframeAnimation *twinkleAnimation=[CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        twinkleAnimation.keyTimes=[NSArray arrayWithObjects:0,0.25,0.5,0.75,1, nil];
        twinkleAnimation.values=values[i-1];
        twinkleAnimation.duration=1.5;
        twinkleAnimation.repeatCount=HUGE_VALF;
        [imgView.layer addAnimation:twinkleAnimation forKey:[NSString stringWithFormat:@"%d", i]];
    }
}

/*
 - (IBAction)powerButtonClicked:(UIButton *)sender {
 // if selected power off/lock, otherwise power on/unlock.
 if(sender.selected)
 {
 NSArray *buttons=[NSArray arrayWithObjects:@"NO", @"YES",nil];
 spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:@"Are You Sure to PowerOff?" buttons:buttons afterDismiss:^(NSString* passcode, int buttonIndex) {
 if(buttonIndex==1)
 {
 NSData *data=[spgMScooterUtilities getDataFromByte:100];
 [[spgBLEService sharedInstance] writePower:data];
 sender.selected=!sender.selected;
 }
 }];
 [[spgAlertViewManager sharedAlertViewManager] show:alert];
 }
 else
 {
 NSData *data=[spgMScooterUtilities getDataFromByte:101];
 [[spgBLEService sharedInstance] writePower:data];
 sender.selected=!sender.selected;
 }
 }*/

- (IBAction)camSwitchClicked:(id)sender {
    if(!self.ARView.hidden)
    {
        [ARVC switchCam];
    }
}

//enter password
- (IBAction)IdentifyPhoneClicked:(id)sender {
    
    NSNumber *num= [spgBLEService sharedInstance].isCertified;
    if(num!=nil && [num boolValue]==NO)
    {
        spgPinView *alert=[[spgPinView alloc] initWithPin:@"9517" afterDismiss:^(NSString *passcode, int buttonIndex) {
            if(buttonIndex==1)
            {
                //shouldPowerOn=YES;
                
                Byte array[]={0x95, 0x17};
                NSData *pinData=[NSData dataWithBytes:array length:2];
                [[spgBLEService sharedInstance] writePassword:pinData];
            }
        }];
        
        [[spgAlertViewManager sharedAlertViewManager] show:alert];
    }
    
    //first load, startScan after centralManager PoweredOn
    //self.bleService=[[spgBLEService sharedInstance] initWithDelegates:self peripheralDelegate:tabBarVC];
    
}

#pragma - test

- (IBAction)TakePhoto:(id)sender {
    [self cameraTriggered:SBSCameraCommandTakePhoto];
}

- (IBAction)RecordVideo:(id)sender {
    UIButton *btn= sender;
    if(!btn.selected)
    {
        [self cameraTriggered:SBSCameraCommandStartRecordVideo];
    }
    else
    {
        [self cameraTriggered:SBSCameraCommandStopRecordVideo];
    }
    btn.selected=!btn.selected;
}

- (IBAction)IdentifyPhone:(id)sender {
    NSString *uniqueIdentifier= [UIDevice currentDevice].identifierForVendor.UUIDString;
    if(uniqueIdentifier)
    {
        NSData *data=[spgMScooterUtilities getDataFromString:uniqueIdentifier startIndex:0 length:18];
        [[spgBLEService sharedInstance] IdentifyPhone:data];
    }
}

- (IBAction)ChangePowerMode:(UIButton *)sender {
    Byte mode=sender.selected?243:245;
    NSData *data=[spgMScooterUtilities getDataFromByte:mode];
    [[spgBLEService sharedInstance] writePower:data];
    
    sender.selected=!sender.selected;
}

- (IBAction)SendPwd:(id)sender {
    Byte array[]={0x95, 0x17};
    NSData *pinData=[NSData dataWithBytes:array length:2];
    [[spgBLEService sharedInstance] writePassword:pinData];
}

-(void)ShowBattery:(NSString *)hexValue{
    UILabel *label=(UILabel *)[self.view viewWithTag:222];
    label.text=hexValue;
}
@end
