//
//  spgScanViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgScanViewController.h"

static NSString *const SCOOTER_SERVICE_UUID=@"4B4681A4-1246-1EEC-AB2B-FE45F896822D";
static const NSInteger CountPerPage = 5;
static const NSInteger ScanInterval = 15;

@interface spgScanViewController ()

@property (strong,nonatomic) spgBLEService *bleService;
@property (strong,nonatomic) NSMutableArray *foundPeripherals;
@property (strong,nonatomic) NSMutableArray *foundStations;
@property (strong,nonatomic) NSMutableArray *groupOfPage;//1,2,3

@end

@implementation spgScanViewController
{
    BOOL isPinning;
    BOOL isScanning;
    NSTimer *scanTimer;
    CGPoint positions[CountPerPage];
    dispatch_group_t group;
    dispatch_queue_t queue;
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
    self.foundPeripherals=[[NSMutableArray alloc] init];
    self.foundStations=[[NSMutableArray alloc] init];
    self.groupOfPage=[[NSMutableArray alloc] init];
    [self createPositions];
    
    group=dispatch_group_create();
    queue=dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    //first load
    if(!self.bleService)
    {
        self.bleService=[[spgBLEService sharedInstance] initWithDelegates:self peripheralDelegate:nil];
    }
    //return back
    else if(self.shouldRetry)
    {
        [spgMScooterUtilities saveMyPeripheralID:nil];
        self.shouldRetry=NO;
        [self retryClicked:nil];
    }
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

-(IBAction)scooterClicked:(id)sender
{
    //navigate
    NSInteger index=[sender superview].tag;
    [self navigateWithDeviceIndex:index isKnown:NO];
}

- (IBAction)retryClicked:(id)sender {
    self.foundView.hidden=YES;
    self.notFoundView.hidden=YES;
    self.retryButton.hidden=YES;
    self.pageControl.hidden=YES;
    
    [self startScan];
}

- (IBAction)pageChanged:(UIPageControl *)sender {
    float offsetX=sender.currentPage * self.view.frame.size.width;
    [self.devicesScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

#pragma - custom methods

-(BOOL)startScan
{
    //ui update
    self.radarImage.hidden=NO;
    self.circlesImage.hidden=YES;
    for(UIView *deviceView in self.devicesScrollView.subviews)
    {
        [deviceView removeFromSuperview];
    }
    [self.devicesScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    //start scan
    [self.foundPeripherals removeAllObjects];
    [self.foundStations removeAllObjects];
    [self.groupOfPage removeAllObjects];
    self.pageControl.numberOfPages =0;
    
    if(!isScanning && self.bleService.centralManager.state==CBCentralManagerStatePoweredOn)
    {
        //start a timer
        scanTimer=[NSTimer scheduledTimerWithTimeInterval:ScanInterval target:self selector:@selector(timerElapsed) userInfo:nil repeats:NO];
        
        //run animation
        [self startSpin];
        
        //find known peripheral
        NSString *idString=[spgMScooterUtilities getMyPeripheralID];
        if(idString)
        {
            NSUUID *knownId=[[NSUUID alloc] initWithUUIDString:idString];
            NSArray *savedIdentifier=[NSArray arrayWithObjects:knownId, nil];
            NSArray *knownPeripherals= [self.bleService.centralManager retrievePeripheralsWithIdentifiers:savedIdentifier];
            if(knownPeripherals.count>0)
            {
                [self.foundPeripherals addObject:knownPeripherals[0]];
                [self navigateWithDeviceIndex:0 isKnown:YES];
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
    //ui update
    self.radarImage.hidden=YES;
    self.circlesImage.hidden=NO;
    
    //stop scan
    if(isScanning)
    {
        isScanning=NO;
        [self.bleService stopScan];
        [self stopSpin];
        
        self.retryButton.enabled=YES;
        self.retryButton.hidden=NO;
    }
}

-(void)timerElapsed
{
    [self stopScan];
    if(self.foundPeripherals.count==0 && self.foundStations.count==0)
    {
        self.foundView.hidden=YES;
        self.notFoundView.hidden=NO;
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

#pragma mark - navigation

-(void)navigateWithDeviceIndex:(NSInteger) index isKnown:(BOOL)isKnown
{
    spgConnectViewController *destination=[[spgConnectViewController alloc] initWithNibName:@"spgConnectViewController" bundle:nil];
    destination.isPeripheralKnown=isKnown;
    if(self.foundPeripherals.count>index)
    {
        self.bleService.peripheral=self.foundPeripherals[index];
    }
    
    destination.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
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
    //NSLog(@"ad:%@", advertisementData.description);
    //NSString *name = advertisementData[kCBAdvDataLocalName]; sometimes nil
    
    dispatch_sync(queue, ^{
        if([peripheral.name hasPrefix:kScooterStationPrefix])//station
        {
            if(![self.foundStations containsObject:peripheral])
            {
                [self.foundStations addObject:peripheral];
                [self addStation:peripheral];
            }
        }
        else if(![self.foundPeripherals containsObject:peripheral])// scooter
        {
            NSDictionary *serviceData=advertisementData[kCBAdvDataServiceData];
            CBUUID* batteryUUID=[CBUUID UUIDWithString:kBatteryServiceUUID];
            NSData* batteryData= serviceData[batteryUUID];
            
            if(batteryData)
            {
                [self.foundPeripherals addObject:peripheral];
                [self addDeviceSite:peripheral battery:batteryData];
            }
        }
    });
}

#pragma - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x/self.view.frame.size.width;
}

#pragma - utilities

-(void)addStation:(CBPeripheral *)peripheral
{
    self.foundView.hidden=NO;
    
    NSInteger pageIndex=[self getPageIndexOfPeripheral:peripheral];
    
    //add new page
    if(pageIndex<0)
    {
        [self addNewPage];
        pageIndex=self.groupOfPage.count-1;
    }
    
    //Add station
    UIView *stationView=[[[NSBundle mainBundle] loadNibNamed:@"spgStation" owner:self options:nil] objectAtIndex:0];
    stationView.frame=CGRectMake(pageIndex * self.view.frame.size.width+80, 200, stationView.frame.size.width, stationView.frame.size.height);
    
    UILabel *name=(UILabel *)[stationView viewWithTag:21];
    name.text=peripheral.name;
    
    [self.devicesScrollView addSubview:stationView];
}

-(void)addDeviceSite:(CBPeripheral *)peripheral battery:(NSData *)batteryData
{
    self.foundView.hidden=NO;
    
    NSInteger pageIndex=[self getPageIndexOfPeripheral:peripheral];
    
    //add new page
    if(pageIndex<0)
    {
        [self addNewPage];
        pageIndex=self.groupOfPage.count-1;
    }
    
    //Add Device
    NSInteger indexInPage=[self scooterNumOfSameGroup:peripheral]-1;
    
    UIView *deviceView=[[[NSBundle mainBundle] loadNibNamed:@"spgDeviceSite" owner:self options:nil] objectAtIndex:0];
    deviceView.tag=[self.foundPeripherals indexOfObject:peripheral];
    deviceView.frame=CGRectMake(pageIndex * self.view.frame.size.width+positions[indexInPage].x, positions[indexInPage].y, deviceView.frame.size.width, deviceView.frame.size.height);
    
    UILabel *name=(UILabel *)[deviceView viewWithTag:11];
    name.text=peripheral.name;
    
    float battery=[spgMScooterUtilities castBatteryToPercent:batteryData];
    UIButton *button=(UIButton *)[deviceView viewWithTag:12];

    UIImage *img=[UIImage imageNamed:[self getScooterImageFromName:peripheral.name battery:battery]];
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateSelected];
    [button addTarget:self action:@selector(scooterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *batteryLabel=(UILabel *)[deviceView viewWithTag:13];
    batteryLabel.text=[NSString stringWithFormat:@"%0.f%%",battery];
    
    [self.devicesScrollView addSubview:deviceView];
}

-(void)addNewPage
{
    //set pageControl
    self.pageControl.numberOfPages=self.groupOfPage.count;
    self.pageControl.hidden=self.pageControl.numberOfPages<=1;
    self.pageControl.currentPage=0;
    
    //set scroll view
    [self.devicesScrollView setContentSize:CGSizeMake(self.view.frame.size.width * self.pageControl.numberOfPages, self.view.frame.size.height)];
}

-(NSInteger)getPageIndexOfPeripheral:(CBPeripheral *)peripheral
{
    NSInteger groupOfPeripheral=[self getGroupOfPeripheral:peripheral.name];
    
    NSInteger pageIndex=-1;
    NSInteger index=0;
    for (NSNumber *groupID in self.groupOfPage) {
        if(groupID.integerValue==groupOfPeripheral)
        {
            pageIndex=index;
            break;
        }
        index++;
    }
    
    if(pageIndex<0)//add new page
    {
        [self.groupOfPage addObject:[NSNumber numberWithInteger:groupOfPeripheral]];
    }
    
    return pageIndex;
}

-(NSInteger)getGroupOfPeripheral:(NSString *)peripheralName
{
    NSInteger groupOfPeripheral;
    if([peripheralName hasPrefix:kScooterStationPrefix])//station
    {
        NSRange range=NSMakeRange(4, 2);
        groupOfPeripheral=[[peripheralName substringWithRange:range] integerValue]-17; //with tag 18,19,20
    }
    else//scooter
    {
        NSRange range=NSMakeRange(10, 2);
        groupOfPeripheral=[[peripheralName substringWithRange:range] integerValue]/5+1;
    }
    
    return groupOfPeripheral;
}

-(NSInteger)scooterNumOfSameGroup:(CBPeripheral *)peripheral
{
    NSInteger groupID=[self getGroupOfPeripheral:peripheral.name];
    int num=0;
    for (CBPeripheral *peripheral in self.foundPeripherals) {
        NSInteger groupOfPeripheral=[self getGroupOfPeripheral:peripheral.name];
        if(groupOfPeripheral==groupID)
        {
            num++;
        }
    }
    
    return num;
}

-(void)createPositions
{
    positions[0]= CGPointMake(45, 65);;
    
    positions[1]= CGPointMake(190, 320);
    positions[2]= CGPointMake(55, 350);
    positions[3]= CGPointMake(10, 180);
    positions[4]= CGPointMake(190, 125);
}

-(NSString *)getScooterImageFromName:(NSString *)name battery:(float) battery
{
    NSString *type=nil;
    if([name hasPrefix:@"S_"])
    {
        type= @"A";
    }
    else if([name hasPrefix:@"M_"])
    {
        type= @"B";
    }
    else if([name hasPrefix:@"L_"])
    {
        type =@"C";
    }
    else//default image
    {
        type=@"A";
    }
    
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
    
    return [NSString stringWithFormat:@"ScooterType%@%@Power.png",type,level];
    
}

@end
