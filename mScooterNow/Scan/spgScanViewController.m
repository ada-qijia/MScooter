//
//  spgScanViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgScanViewController.h"
#import "spgPeripheralView.h"
#import "spgScooterPeripheral.h"

static NSString *const SCOOTER_SERVICE_UUID=@"4B4681A4-1246-1EEC-AB2B-FE45F896822D";
static const NSInteger scooterCount = 10;
static const NSInteger stationCount = 3;
static const NSInteger stateChangeInterval=1.5;
static const NSInteger stationAdvInterval=2;
static const NSInteger scooterTimeArrayCount=3;


@interface spgScanViewController ()

@property (strong,nonatomic) spgBLEService *bleService;
@property (strong,atomic) NSMutableDictionary *foundPeripherals;
@property (strong,atomic) NSMutableDictionary *foundStations;

@end

@implementation spgScanViewController
{
    BOOL isPinning;
    BOOL isScanning;
    CGPoint scooterPos[scooterCount];
    CGPoint stationPos[stationCount];
    NSMutableArray *availableScooterPos;
    NSMutableArray *availableStationPos;
    dispatch_queue_t queue;
    UIImage *dotImage;
    UIImage *triangleImage;
    NSTimer *observerTimer;
}

#pragma - UIViewController methods

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
    
    //initialize
    self.view.backgroundColor = BackgroundImageColor;
    self.foundPeripherals=[[NSMutableDictionary alloc] init];
    self.foundStations=[[NSMutableDictionary alloc] init];
    [self createPositions];
    queue=dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
    dotImage=[UIImage imageNamed:@"dot.png"];
    triangleImage=[UIImage imageNamed:@"triangle.png"];
    
    //first load, startScan after centralManager PoweredOn
    self.bleService=[[spgBLEService sharedInstance] initWithDelegates:self peripheralDelegate:nil];
    
    CGSize screenSize=self.view.frame.size;
    [self.devicesScrollView setContentSize:CGSizeMake(screenSize.height, screenSize.height)];
    [self.devicesScrollView setContentOffset:CGPointMake((screenSize.height-screenSize.width)/2, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

CBPeripheral *selectedPeripheral;

-(IBAction)scooterClicked:(UIButton *)sender
{
    [self stopScan];
    
    CBPeripheral *peripheral= ((spgPeripheralView *)[sender superview]).peripheral;
    float battery=((spgPeripheralView *)[sender superview]).battery;
    self.detailView.hidden=NO;
    self.deviceNameLabel.text=peripheral.name;
    self.batteryLabel.text=battery>0?[NSString stringWithFormat:@"%0.f%%",battery]:@"-";
    self.distanceLabel.text=battery>0?[NSString stringWithFormat:@"%0.fKM",battery/2.5]:@"-";
    
    selectedPeripheral=peripheral;
}

- (IBAction)pickupClicked:(id)sender {
    self.detailView.hidden=YES;
    //navigate
    [self navigateWithPeripheral:selectedPeripheral];
}

- (IBAction)backClicked:(id)sender {
    self.detailView.hidden=YES;
}

- (IBAction)retryClicked:(id)sender {
    [self startScan];
}

#pragma - custom methods

-(BOOL)startScan
{
    //observe peripheral state
    observerTimer=[NSTimer scheduledTimerWithTimeInterval:stateChangeInterval/1.5 target:self selector: @selector(timerElapsed) userInfo:nil repeats:YES];
    
    //ui update
    self.radarImage.hidden=NO;
    self.circlesImage.hidden=YES;
    self.retryButton.hidden=YES;
    
    for (UIView *flagView in self.scopeView.subviews) {
        [flagView removeFromSuperview];
    }
    for(UIView *deviceView in self.devicesScrollView.subviews)
    {
        [deviceView removeFromSuperview];
    }
    
    [availableScooterPos removeAllObjects];
    for(int i=0;i<scooterCount;i++)
    {
        [availableScooterPos addObject:[NSNumber numberWithInt:i]];
    }
    
    [availableStationPos removeAllObjects];
    for(int i=0;i<stationCount;i++)
    {
        [availableStationPos addObject:[NSNumber numberWithInt:i]];
    }

    
    //start scan
    [self.foundPeripherals removeAllObjects];
    [self.foundStations removeAllObjects];
    
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
                [self.foundPeripherals setObject:[self CreateNewSpgScooterPeripheral] forKey:knownPeripherals[0]];
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

-(spgScooterPeripheral *)CreateNewSpgScooterPeripheral
{
    spgScooterPeripheral *entity=[[spgScooterPeripheral alloc] init];
    
    NSMutableArray *array=[[NSMutableArray alloc] init];
    for(int i=0;i<scooterTimeArrayCount;i++)
    {
        [array addObject:[NSDate dateWithTimeIntervalSince1970:0]];
    }
    entity.RecentTimeArray=array;
    entity.LastPosition=-1;
    
    return entity;
}

-(void)stopScan
{
    //stop observe
    [observerTimer invalidate];
    
    //ui update
    self.radarImage.hidden=YES;
    self.circlesImage.hidden=NO;
    
    //stop scan
    if(isScanning)
    {
        isScanning=NO;
        [self.bleService stopScan];
        [self stopSpin];
        
        self.retryButton.hidden=NO;
    }
}

-(void)timerElapsed
{
    NSDate *dateNow=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSMutableDictionary *stations=[NSMutableDictionary dictionaryWithDictionary:self.foundStations];
    
    for (CBPeripheral *peripheral in stations) {
        NSDate *lastDate=[stations objectForKey:peripheral];
        NSTimeInterval interval= [dateNow timeIntervalSinceDate:lastDate];
        if(interval>=stationAdvInterval && interval<=stateChangeInterval+stationAdvInterval)//vague
        {
            [self updateStationUIState:peripheral state:BLEDeviceStateVague];
        }
        else if(interval>stateChangeInterval+stationAdvInterval)//disappear
        {
            [self updateStationUIState:peripheral state:BLEDeviceStateInactive];
        }
    }
    
    NSMutableDictionary *scooters=[NSMutableDictionary dictionaryWithDictionary:self.foundPeripherals];
    for (CBPeripheral *peripheral in scooters) {
        spgScooterPeripheral *entity=[scooters objectForKey:peripheral];
        int recentCount=0;
        for (NSDate *date in entity.RecentTimeArray) {
            NSTimeInterval interval=[dateNow timeIntervalSinceDate:date];
            if(interval<=stateChangeInterval)
            {
                recentCount++;
            }
        }

        if(recentCount==0)
        {
            [self updateScooterUIState:peripheral battery:entity.BatteryData state:BLEDeviceStateInactive];
        }
        else if(recentCount<=2)
        {
            [self updateScooterUIState:peripheral battery:entity.BatteryData state:BLEDeviceStateVague];
        }
        else
        {
            [self updateScooterUIState:peripheral battery:entity.BatteryData state:BLEDeviceStateActive];
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
    spgConnectViewController *destination=[[spgConnectViewController alloc] initWithNibName:@"spgConnectViewController" bundle:nil];
    self.bleService.peripheral=peripheral;
    
    //destination.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:destination animated:YES completion:nil];
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
    
    NSDate *dateNow=[NSDate date];
    dispatch_sync(queue, ^{
        if([peripheral.name hasPrefix:kScooterStationPrefix])//station
        {
            NSLog(@"ad:%@", advertisementData.description);
            
            NSDate *lastDate=(NSDate *)self.foundStations[peripheral];
            [self.foundStations setObject:dateNow forKey:peripheral];
            
            if(!lastDate)//first add
            {
                [self updateStationUIState:peripheral state:BLEDeviceStateVague];
            }
            else if([dateNow timeIntervalSinceDate:lastDate]<=stateChangeInterval)
            {
                [self updateStationUIState:peripheral state:BLEDeviceStateActive];
            }
            else
            {
                [self updateStationUIState:peripheral state:BLEDeviceStateVague];
            }
        }
        else // scooter
        {
            NSDictionary *serviceData=advertisementData[kCBAdvDataServiceData];
            CBUUID* batteryUUID=[CBUUID UUIDWithString:kBatteryServiceUUID];
            NSData* batteryData= serviceData[batteryUUID];
            
            if(batteryData)
            {
                spgScooterPeripheral *entity= self.foundPeripherals[peripheral];
                //first add
                if(!entity)
                {
                    entity=[self CreateNewSpgScooterPeripheral];
                    [self.foundPeripherals setObject:entity forKey:peripheral];
                }
                entity.BatteryData=batteryData;
                [entity.RecentTimeArray removeObjectAtIndex:0];
                [entity.RecentTimeArray addObject:dateNow];
            }
        }
    });
}

#pragma - utilities

-(void)updateStationUIState:(CBPeripheral *)peripheral state:(BLEDeviceState)stationState
{
    NSLog(@"station state:%ld",stationState);
    
    spgPeripheralView *stationView=nil;
    for(spgPeripheralView *peripheralView in self.devicesScrollView.subviews)
    {
        if(peripheralView.peripheral==peripheral)
        {
            stationView=peripheralView;
            break;
        }
    }
    
    switch (stationState) {
        case BLEDeviceStateActive:
        case BLEDeviceStateVague:
        {
            NSInteger index=-1;
            if(stationView==nil)
            {
                //Add station
                stationView=[[[NSBundle mainBundle] loadNibNamed:@"spgStation" owner:self options:nil] objectAtIndex:0];
                index=((NSNumber *)availableStationPos[0]).integerValue;
                stationView.frame=CGRectMake(stationPos[index].x, stationPos[index].y, stationView.frame.size.width, stationView.frame.size.height);
                stationView.tag=index;
                [availableStationPos removeObjectAtIndex:0];
                
                [self.devicesScrollView addSubview:stationView];
                [self scaleInAnimation:stationView];
                
                [self addDeviceFlagToScope:stationView.frame.origin withTag:stationView.tag isScooter:NO];
            }
            else
            {
                index=[self.devicesScrollView.subviews indexOfObject:stationView];
            }
            
            stationView.peripheral=peripheral;
        }
            stationView.alpha=stationState==BLEDeviceStateActive?1.0:0.5;
            break;
        case BLEDeviceStateInactive:
            for(int i=0;i<stationCount;i++)
            {
                if(CGPointEqualToPoint(stationPos[i],stationView.frame.origin))
                {
                    [availableStationPos insertObject:[NSNumber numberWithInt:i] atIndex:0];
                    break;
                }
            }
            
            [self scaleOutAnimation:stationView];
            [self performSelector:@selector(removeViewInScrollView:) withObject:stationView afterDelay:0.5];
            
            [self.foundStations removeObjectForKey:peripheral];
            break;
        default:
            break;
    }
}

-(void)updateScooterUIState:(CBPeripheral *)peripheral battery:(NSData *)batteryData state:(BLEDeviceState)stationState
{
    NSLog(@"scooter state:%ld",stationState);
    
    spgPeripheralView *scooterView=nil;
    for(spgPeripheralView *peripheralView in self.devicesScrollView.subviews)
    {
        if(peripheralView.peripheral==peripheral)
        {
            scooterView=peripheralView;
            break;
        }
    }
    
    switch (stationState) {
        case BLEDeviceStateActive:
        case BLEDeviceStateVague:
        {
            NSInteger index=-1;
            if(scooterView==nil)
            {
                //Add scooter
                scooterView=[[[NSBundle mainBundle] loadNibNamed:@"spgDeviceSite" owner:self options:nil] objectAtIndex:0];
                [self.devicesScrollView addSubview:scooterView];
                index=((NSNumber *)availableScooterPos[0]).integerValue;
                scooterView.frame=CGRectMake(scooterPos[index].x, scooterPos[index].y, scooterView.frame.size.width, scooterView.frame.size.height);
                scooterView.tag=index+stationCount;
                [availableScooterPos removeObjectAtIndex:0];
                
                [self scaleInAnimation:scooterView];
                [self addDeviceFlagToScope:scooterView.frame.origin withTag:scooterView.tag isScooter:YES];
            }
            else
            {
                index=[self.devicesScrollView.subviews indexOfObject:scooterView];
            }
            
            scooterView.peripheral=peripheral;
            
            if(batteryData)
            {
                float battery=[spgMScooterUtilities castBatteryToPercent:batteryData];
                UIImageView *powerImage=(UIImageView *)[scooterView viewWithTag:11];
                powerImage.image=[UIImage imageNamed:[self getBatteryImageFromBattery:battery]];
                
                UIButton *button=(UIButton *)[scooterView viewWithTag:12];
                UIImage *img=[UIImage imageNamed:[spgMScooterUtilities getScooterImageFromName:peripheral.name]];
                [button setImage:img forState:UIControlStateNormal];
                //[button setImage:img forState:UIControlStateSelected];
                [button addTarget:self action:@selector(scooterClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                scooterView.battery=battery;
            }
            else
            {
                scooterView.battery=-1;
            }
        }
            scooterView.alpha=stationState==BLEDeviceStateActive?1.0:0.5;
            break;
        case BLEDeviceStateInactive:
            for(int i=0;i<scooterCount;i++)
            {
                if(CGPointEqualToPoint(scooterPos[i],scooterView.frame.origin))
                {
                    [availableScooterPos insertObject:[NSNumber numberWithInt:i] atIndex:0];
                    break;
                }
            }
            
            [self scaleOutAnimation:scooterView];
            [self performSelector:@selector(removeViewInScrollView:) withObject:scooterView afterDelay:0.5];
            [self.foundPeripherals removeObjectForKey:peripheral];
            break;
        default:
            break;
    }
    
}

-(void)removeViewInScrollView:(UIView *)view
{
    [view removeFromSuperview];
    //remove related flag in scope view
    [[self.scopeView viewWithTag:view.tag] removeFromSuperview];
}

-(void)addDeviceFlagToScope:(CGPoint)originInScrollView withTag:(NSInteger)tag isScooter:(BOOL)isScooter
{
    UIImageView *imgView=[UIImageView new];
    NSString *imgName=isScooter?@"scooterFlag.png":@"stationFlag.png";
    imgView.image=[UIImage imageNamed:imgName];
    float ratio=self.scopeView.frame.size.height/self.view.frame.size.height;
    imgView.frame=CGRectMake(originInScrollView.x*ratio, originInScrollView.y*ratio, 14, 14);
    imgView.tag=tag;
    [self.scopeView addSubview:imgView];
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
    
    stationPos[0]=CGPointMake(232, 183);
    stationPos[1]=CGPointMake(180, 267);
    stationPos[2]=CGPointMake(283, 267);
    
    availableScooterPos=[NSMutableArray array];
    for(int i=0;i<scooterCount;i++)
    {
        [availableScooterPos addObject:[NSNumber numberWithInt:i]];
    }
    
    availableStationPos=[NSMutableArray array];
    for(int i=0;i<stationCount;i++)
    {
        [availableStationPos addObject:[NSNumber numberWithInt:i]];
    }
}

-(NSString *)getBatteryImageFromBattery:(float) battery
{
    NSString *level=nil;
    if(battery<=30)
    {
        level=@"Low";
    }
    else if(battery>=60)
    {
        level=@"High";
    }
    else
    {
        level=@"Medium";
    }
    
    return [NSString stringWithFormat:@"power%@.png",level];
}
@end
