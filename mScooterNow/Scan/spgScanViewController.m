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
#import "spgAlertViewManager.h"

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
    NSTimer *loopScanTimer;
    
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
    
    UISwipeGestureRecognizer *horizontalLeftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalLeftSwipe:)];
    horizontalLeftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:horizontalLeftSwipe];
    
    UISwipeGestureRecognizer *horizontalRightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalRightSwipe:)];
    horizontalRightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontalRightSwipe];
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

#pragma mark - gesture methods

//cycle
-(void)reportHorizontalLeftSwipe:(UIGestureRecognizer *)recognizer
{
    if(self.foundPeripherals.count>1)
    {
        int count=(int)self.foundPeripherals.count;
        int selectedIndex=(int)[self.foundPeripherals indexOfObject:visibleScooter];
        int nextIndex=(selectedIndex+1+count)%count;
        spgScooterPeripheral *scooter=self.foundPeripherals[nextIndex];
        
        [self updateScooter:scooter withAnimation:YES animationNext:YES];
    }
}

//cycle
-(void)reportHorizontalRightSwipe:(UIGestureRecognizer *)recognizer
{
    if(self.foundPeripherals.count>1)
    {
        int count=(int)self.foundPeripherals.count;
        int selectedIndex=(int)[self.foundPeripherals indexOfObject:visibleScooter];
        int preIndex=(selectedIndex-1+count)%count;
        spgScooterPeripheral *scooter=self.foundPeripherals[preIndex];
        
        [self updateScooter:scooter withAnimation:YES animationNext:NO];
    }
}

#pragma - UI interaction

- (IBAction)pickupClicked:(id)sender {
    NSArray *buttons=[NSArray arrayWithObjects:@"NO", @"YES",nil];
    spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:@"Are You Sure to Pick Up This Scooter?" buttons:buttons afterDismiss:^(NSString* passcode, int buttonIndex) {
        if(buttonIndex==1)
        {
            //navigate
            if(visibleScooter)
            {
                [self navigateWithPeripheral:visibleScooter.Peripheral];
            }
        }
    }];
    [[spgAlertViewManager sharedAlertViewManager] show:alert];
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma - custom methods

-(void)startScan
{
    //run animation
    [self startSpin];
    
    //spin 3 sec before real scan.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //Clear
        visibleScooter=nil;
        [self.foundPeripherals removeAllObjects];
        [self resetAvailableScooterPos];
        
        //ui update
        self.radarImage.hidden=NO;
        for (UIView *flagView in self.scopeView.subviews) {
            [flagView removeFromSuperview];
        }
        
        //observe peripheral state
        observerTimer=[NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(timerElapsed:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:observerTimer forMode:NSRunLoopCommonModes];
        
        //start scan
        if(!isScanning && self.bleService.centralManager.state==CBCentralManagerStatePoweredOn)
        {
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
                    [self loopScan];
                }
            }
            else
            {
                [self.bleService startScan];
                [self loopScan];
            }
            
            isScanning=YES;
        }
    });
}

-(void)stopScan
{
    //stop loopScan timer
    [loopScanTimer invalidate];
    
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

-(void)loopScan
{
    loopScanTimer=[NSTimer timerWithTimeInterval:110 target:self selector:@selector(autoRestartScan:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:loopScanTimer forMode:NSRunLoopCommonModes];
}

-(void)autoRestartScan:(NSTimer *)timer
{
    [self.bleService stopScan];
    [self.bleService startScan];
}

//observe peripheral state
-(void)timerElapsed:(NSTimer *)timer
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

-(void)breathInAnimation:(UIView *)view
{
    [CATransaction begin];
    [view.layer removeAllAnimations];
    [CATransaction commit];
    
    view.hidden=NO;
    view.alpha=0.1;
    view.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.alpha=1.0;
                         view.transform=CGAffineTransformIdentity;
                     } completion:nil];
}

-(void)breathOutAnimation:(UIView *)view
{
    [CATransaction begin];
    [view.layer removeAllAnimations];
    [CATransaction begin];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn  animations:^{
        view.alpha=0.1;
        view.transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    } completion:^(BOOL finished) {
        if(finished)
        {
            view.hidden=YES;
        }
    }];
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
    spgAlertViewBlock afterDismissBlock=nil;
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self startScan];
            break;
        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStateUnauthorized:
            message=central.state==CBCentralManagerStatePoweredOff? @"Please turn on Bluetooth to allow ScooterNow to connect to accessories.":@"Please make sure ScooterNow is authorized to use Bluetooth low energy.";
            /*
             afterDismissBlock=^(NSString *passcode, int buttonIndex) {
             //NSURL* url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
             //if([[UIApplication sharedApplication] canOpenURL:url])
             {
             NSURL* url=[NSURL URLWithString:@"prefs:root=General&path=Bluetooth"];
             [[UIApplication sharedApplication] openURL:url];
             }
             };
             */
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

//scan multiple devices
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSString *name = advertisementData[kCBAdvDataLocalName]; sometimes nil
    //scooter
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
    
    //NSLog(@"%@",advertisementData);
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
                [self updateScooter:self.foundPeripherals[nextIndex] withAnimation:NO animationNext:NO];
            }
            else
            {
                [self updateScooter:nil withAnimation:NO animationNext:NO];
            }
        }
        else if(newState==BLEDeviceStateActive||newState==BLEDeviceStateVague)
        {
            [self updateScooter:scooter withAnimation:NO animationNext:NO];
        }
    }
    
    //scooter array
    if(newState==BLEDeviceStateInactive)
    {
        [self.foundPeripherals removeObject:scooter];
    }
}

//change the current visible to scooter in param.
//useAnimation means left/right switch scooter.
-(void)updateScooter:(spgScooterPeripheral *)scooter withAnimation:(BOOL)useAnimation animationNext:(BOOL)next
{
    if(useAnimation)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.type = kCATransitionPush;
        transition.subtype =next? kCATransitionFromRight:kCATransitionFromLeft;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [self.scooterView.layer addAnimation:transition forKey:nil];
    }
    
    if(scooter)
    {
        if(scooter.CurrentState==BLEDeviceStateActive||scooter.CurrentState==BLEDeviceStateVague)
        {
            float battery=[spgMScooterUtilities castBatteryToPercent:scooter.BatteryData];
            
            UIImageView *imgView=(UIImageView *)[self.scooterView viewWithTag:11];
            imgView.image=[UIImage imageNamed:[spgMScooterUtilities getBatteryImageFromValue:battery]];
            
            UILabel *nameLabel=(UILabel *)[self.scooterView viewWithTag:13];
            nameLabel.text=scooter.Peripheral.name;
            
            UIButton *addButton=(UIButton *)[self.scooterView viewWithTag:14];
            addButton.hidden=scooter.CurrentState==BLEDeviceStateActive?NO:YES;
            self.scooterView.alpha=addButton.hidden?0.5:1;
            
            //first show with animation
            if(visibleScooter==nil)
            {
                [self breathInAnimation:self.scooterView];
            }
        }
    }
    else//disappear with animation
    {
        [self breathOutAnimation:self.scooterView];
    }
    
    visibleScooter=scooter;
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

-(void)resetAvailableScooterPos
{
    if(availableScooterPos)
    {
        [availableScooterPos removeAllObjects];
    }
    else
    {
        availableScooterPos=[NSMutableArray array];
    }
    
    for(int i=0;i<scooterCount;i++)
    {
        [availableScooterPos addObject:[NSNumber numberWithInt:i]];
    }
}

@end

