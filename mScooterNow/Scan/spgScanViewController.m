//
//  spgScanViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgScanViewController.h"
#import "spgScooterPeripheral.h"
#import "spgTabBarViewController.h"

static NSString *const SCOOTER_SERVICE_UUID=@"4B4681A4-1246-1EEC-AB2B-FE45F896822D";
static const NSInteger scooterCount = 10;
static const NSInteger stateChangeInterval=4;
static const NSInteger scooterTimeArrayCount=10;


@interface spgScanViewController ()

@property (strong,nonatomic) spgBLEService *bleService;
//queue
@property (strong,atomic) NSMutableArray *foundPeripherals;

@end

@implementation spgScanViewController
{
    BOOL isPinning;
    BOOL isScanning;
    
    CGPoint scooterPos[scooterCount];
    NSMutableArray *availableScooterPos;
    
    UIImage *dotImage;
    NSTimer *observerTimer;
    
    spgScooterPeripheral *visibleScooter;
}

#pragma - LifeCycle methods

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
    
    //set background
    BOOL isCampusMode=[[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey] isEqualToString:kScenarioModeCampus];
    NSString *imageName=isCampusMode?@"bgCampus.png":@"bgPersonal.png";
    self.view.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    
    //initialize
    self.foundPeripherals=[[NSMutableArray alloc] init];
    //first load, startScan after centralManager PoweredOn
    self.bleService=[[spgBLEService sharedInstance] initWithDelegates:self peripheralDelegate:nil];
    
    [self createPositions];
    dotImage=[UIImage imageNamed:@"dot.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self stopScan];
    [super viewWillDisappear:animated];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma - UI interaction

- (IBAction)pickupClicked:(id)sender {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to pick up this scooter?" delegate:self  cancelButtonTitle:@"CANCEL" otherButtonTitles:@"PICK UP",nil];
    [alert show];
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//cycle
- (IBAction)preClicked:(id)sender {
    int count=(int)self.foundPeripherals.count;
    int selectedIndex=(int)[self.foundPeripherals indexOfObject:visibleScooter];
    int preIndex=(selectedIndex-1+count)%count;
    spgScooterPeripheral *scooter=self.foundPeripherals[preIndex];
    
    [self updateScooter:scooter];
}

//cycle
- (IBAction)nextClicked:(id)sender {
    int count=(int)self.foundPeripherals.count;
    int selectedIndex=(int)[self.foundPeripherals indexOfObject:visibleScooter];
    int nextIndex=(selectedIndex+1+count)%count;
    spgScooterPeripheral *scooter=self.foundPeripherals[nextIndex];
    
    [self updateScooter:scooter];
}

#pragma pick up alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        //navigate
        if(visibleScooter)
        {
            [self navigateWithPeripheral:visibleScooter.Peripheral];
        }
    }
}


#pragma - custom methods

-(BOOL)startScan
{
    //observe peripheral state
    observerTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector: @selector(timerElapsed) userInfo:nil repeats:YES];
    
    //ui update
    self.radarImage.hidden=NO;
    for (UIView *flagView in self.scopeView.subviews) {
        [flagView removeFromSuperview];
    }
    
    //start scan
    visibleScooter=nil;
    [self.foundPeripherals removeAllObjects];
    
    if(!isScanning && self.bleService.centralManager.state==CBCentralManagerStatePoweredOn)
    {
        //run animation
        [self startSpin];
        
        BOOL isPersonal=[[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey] isEqualToString:kScenarioModePersonal];
        NSString *knownUUIDString=[spgMScooterUtilities getPreferenceWithKey:kMyPeripheralIDKey];
        
        //find known peripheral
        if(isPersonal && knownUUIDString)
        {
            NSUUID *knownUUID=[[NSUUID alloc] initWithUUIDString:knownUUIDString];
            NSArray *savedIdentifier=[NSArray arrayWithObjects:knownUUID, nil];
            NSArray *knownPeripherals= [self.bleService.centralManager retrievePeripheralsWithIdentifiers:savedIdentifier];
            if(knownPeripherals.count>0)
            {
                spgScooterPeripheral *scooter=[[spgScooterPeripheral alloc] initWithPeripheral:knownPeripherals[0] timeArrayCapacity:scooterTimeArrayCount];
                [self.foundPeripherals addObject:scooter];
                [self navigateWithPeripheral:knownPeripherals[0]];
            }
            else
            {
                [self.bleService startScan];
            }
        }
        else
        {
            [self.bleService startScan];
        }
        
        isScanning=YES;
        return true;
    }
    return false;
}

-(void)stopScan
{
    //stop observe
    [observerTimer invalidate];
    
    //ui update
    self.radarImage.hidden=YES;
    
    //stop scan
    if(isScanning)
    {
        isScanning=NO;
        [self.bleService stopScan];
        [self stopSpin];
    }
}

-(void)timerElapsed
{
    NSDate *dateNow=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSMutableArray *scooters=[NSMutableArray arrayWithArray:self.foundPeripherals];
    
    for (spgScooterPeripheral *scooter in scooters) {
        int recentCount=0;
        for (NSDate *date in scooter.RecentTimeArray) {
            NSTimeInterval interval=[dateNow timeIntervalSinceDate:date];
            if(interval<=stateChangeInterval)
            {
                recentCount++;
            }
        }
        
        BLEDeviceState oldState=scooter.CurrentState;
        //change state
        if(recentCount==0)
        {
            scooter.CurrentState=BLEDeviceStateInactive;
        }
        else if(recentCount<=3)
        {
            scooter.CurrentState=BLEDeviceStateVague;
        }
        else if(recentCount>=6)
        {
            scooter.CurrentState=BLEDeviceStateActive;
        }
        
        //if current visible scooter state changed, update UI here
        if(oldState!=scooter.CurrentState)
        {
            [self scooterStateChanged:scooter oldState:oldState newState:scooter.CurrentState];
        }
    }
}

#pragma radar spin animation

-(void)runSpinAnimation
{
    CABasicAnimation *rotationAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.repeatCount=HUGE_VALF;
    rotationAnimation.byValue=[NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration=2;
    rotationAnimation.cumulative=YES;
    
    [self.radarImage.layer addAnimation:rotationAnimation forKey: @"rotatioinAnimation"];
}

-(void)pauseSpinAnimation
{
    isPinning=NO;
    CFTimeInterval pausedTime=[self.radarImage.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.radarImage.layer.speed=0.0;
    self.radarImage.layer.timeOffset=pausedTime;
}

-(void)resumeSpinAnimation
{
    isPinning=YES;
    CFTimeInterval pausedTime=[self.radarImage.layer timeOffset];
    self.radarImage.layer.speed=1.0;
    self.radarImage.layer.timeOffset=0.0;
    self.radarImage.layer.beginTime=0.0;
    CFTimeInterval timeSincePause=[self.radarImage.layer convertTime:CACurrentMediaTime() fromLayer:nil]-pausedTime;
    self.radarImage.layer.beginTime=timeSincePause;
}

-(void)stopSpinAnimation
{
    [self.radarImage.layer removeAllAnimations];
}

-(void)startSpin
{
    if(!isPinning)
    {
        isPinning=YES;
        if(self.radarImage.layer.speed==0.0)
        {
            [self resumeSpinAnimation];
        }
        else
        {
            [self runSpinAnimation];
        }
    }
}

-(void)stopSpin
{
    if(isPinning)
    {
        isPinning=NO;
        [self pauseSpinAnimation];
    }
}

#pragma mark - scooter & station animation

-(void)breathAnimation:(UIView *)view
{
    view.alpha=0;
    view.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.3, 0.3);
    [UIView animateWithDuration:1.5 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse) animations:^{view.alpha=1.0; view.transform=CGAffineTransformIdentity;} completion:nil];
}

-(void)scaleInAnimation:(UIView *)view
{
    view.alpha=0;
    view.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{view.transform=CGAffineTransformIdentity;view.alpha=1;} completion:nil];
}

-(void)scaleOutAnimation:(UIView *)view
{
    view.transform=CGAffineTransformIdentity;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse) animations:^{view.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);view.alpha=0;} completion:nil];
}

#pragma mark - navigation

-(void)navigateWithPeripheral:(CBPeripheral *) peripheral
{
    self.bleService.peripheral=peripheral;
    
    //backToTabBarViewController
    UIViewController *currentVC=self;
    while (currentVC && ![currentVC isKindOfClass:[UITabBarController class]]) {
        [currentVC dismissViewControllerAnimated:NO completion:nil];
        currentVC=currentVC.presentingViewController;
    }
    
    spgTabBarViewController *tabBarVC=(spgTabBarViewController *)currentVC;
    [tabBarVC showDashboardGauge];
}

#pragma - spgBLEServiceDiscoverPeripheralsDelegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *message=nil;
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStatePoweredOn:
            [self startScan];
            break;
        case CBCentralManagerStateUnauthorized:
            message=@"Turn on Bluetooth to allow 'Scooter Now' to connect to Accessories.";
            break;
        case CBCentralManagerStateUnsupported:
            message=@"This platform does not support Bluetooth low energy.";
            break;
        default:
            message=@"'Scooter Now' can not connect to Accessories.";
            break;
    }
    
    if(message!=nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

//scan multiple devices
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSString *name = advertisementData[kCBAdvDataLocalName]; sometimes nil
    // scooter
    NSDate *dateNow=[NSDate date];
    NSDictionary *serviceData=advertisementData[kCBAdvDataServiceData];
    CBUUID* batteryUUID=[CBUUID UUIDWithString:kBatteryServiceUUID];
    NSData* batteryData= serviceData[batteryUUID];
    
    if(batteryData)
    {
        spgScooterPeripheral *scooter=nil;
        for (spgScooterPeripheral *entity in self.foundPeripherals) {
            if(entity.Peripheral==peripheral)
            {
                scooter=entity;
                break;
            }
        }
        
        //first add
        if(!scooter)
        {
            scooter=[[spgScooterPeripheral alloc] initWithPeripheral:peripheral timeArrayCapacity:scooterTimeArrayCount];
            [self.foundPeripherals addObject:scooter];
        }
        
        scooter.BatteryData=batteryData;
        [scooter.RecentTimeArray removeObjectAtIndex:0];
        [scooter.RecentTimeArray addObject:dateNow];
    }
}

#pragma - utilities

//update pre/next button, scooter UI, scopeView
-(void)scooterStateChanged:(spgScooterPeripheral *)scooter oldState:(BLEDeviceState) oldState newState:(BLEDeviceState) newState
{
    //scope view
    UIImageView *flagView = (UIImageView *)[self.scopeView viewWithTag:scooter.FlagTag];
    if(newState==BLEDeviceStateActive||newState==BLEDeviceStateVague)
    {
        if(scooter.FlagTag>=0 && flagView)
        {
        }
        else
        {
            scooter.FlagTag=(int)((NSNumber *)availableScooterPos[0]).integerValue;
            [availableScooterPos removeObjectAtIndex:0];
            
            flagView=[UIImageView new];
            CGPoint point=scooterPos[scooter.FlagTag];
            float ratio=self.scopeView.frame.size.height/self.view.frame.size.height;
            flagView.frame=CGRectMake(point.x*ratio, point.y*ratio, 14, 14);
            flagView.tag=scooter.FlagTag;
            [self.scopeView addSubview:flagView];
        }
        
        NSString *url=newState==BLEDeviceStateActive?@"scooterFlagActive.png":@"scooterFlagVague.png";
        flagView.image=[UIImage imageNamed:url];
    }
    else if(newState==BLEDeviceStateInactive)
    {
        [availableScooterPos insertObject:[NSNumber numberWithInt:(int)scooter.FlagTag] atIndex:0];
        [flagView removeFromSuperview];
    }
    
    //scooter UI,
    //this changed foundPeripherals, should be left bottom
    if(visibleScooter==nil||scooter==visibleScooter)
    {
        if(newState==BLEDeviceStateInactive)
        {
            int selectedIndex=(int)[self.foundPeripherals indexOfObject:visibleScooter];
            int count=(int)self.foundPeripherals.count;
            if(count>1)//show next
            {
                int nextIndex=(selectedIndex+1)%count;
                [self updateScooter:self.foundPeripherals[nextIndex]];
            }
            else
            {
                [self updateScooter:nil];
            }
        }
        else if(newState==BLEDeviceStateActive||newState==BLEDeviceStateVague)
        {
            [self updateScooter:scooter];
        }
    }
    
    //scooter array
    if(newState==BLEDeviceStateInactive)
    {
        [self.foundPeripherals removeObject:scooter];
    }
    
    //pre/next button
    self.preButton.hidden=self.foundPeripherals.count<=1;
    self.nextButton.hidden=self.preButton.hidden;
}

-(void)updateScooter:(spgScooterPeripheral *)scooter
{
    visibleScooter=scooter;
    if(scooter)
    {
        if(scooter.CurrentState==BLEDeviceStateActive||scooter.CurrentState==BLEDeviceStateVague)
        {
            float battery=[spgMScooterUtilities castBatteryToPercent:scooter.BatteryData];
            UILabel *batteryLabel=(UILabel *)[self.scooterView viewWithTag:11];
            batteryLabel.text= battery>0?[NSString stringWithFormat:@"%0.f%%",battery]:@"-";
            UILabel *rangeLabel=(UILabel *)[self.scooterView viewWithTag:12];
            rangeLabel.text=battery>0?[NSString stringWithFormat:@"%0.fKM",battery/2.5]:@"-";
            UILabel *nameLabel=(UILabel *)[self.scooterView viewWithTag:13];
            nameLabel.text=scooter.Peripheral.name;
            
            UIButton *addButton=(UIButton *)[self.scooterView viewWithTag:14];
            addButton.hidden=scooter.CurrentState==BLEDeviceStateActive?NO:YES;
            //self.scooterView.alpha=scooter.CurrentState==BLEDeviceStateActive?1:0.7;
            
            self.scooterView.hidden=NO;
        }
    }
    else
    {
        self.scooterView.hidden=YES;
    }
}

-(void)createPositions
{
    //from center to edge
    scooterPos[0]= CGPointMake(363, 145);
    scooterPos[1]= CGPointMake(140, 134);
    scooterPos[2]= CGPointMake(244, 373);
    scooterPos[3]= CGPointMake(132, 329);
    scooterPos[4]= CGPointMake(445, 293);
    scooterPos[5]= CGPointMake(243, 32);
    scooterPos[6]= CGPointMake(358, 403);
    scooterPos[7]= CGPointMake(46, 254);
    scooterPos[8]= CGPointMake(485, 104);
    scooterPos[9]= CGPointMake(54, 32);
    
    availableScooterPos=[NSMutableArray array];
    for(int i=0;i<scooterCount;i++)
    {
        [availableScooterPos addObject:[NSNumber numberWithInt:i]];
    }
}

@end

