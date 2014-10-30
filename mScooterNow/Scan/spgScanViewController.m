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
static const NSInteger ScanInterval = 6;

@interface spgScanViewController ()

@property (strong,nonatomic) spgBLEService *bleService;
@property (strong,nonatomic) NSMutableArray *foundPeripherals;

@end

@implementation spgScanViewController
{
    BOOL isPinning;
    BOOL isScanning;
    NSTimer *scanTimer;
    CGPoint positions[CountPerPage];
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
    [self createPositions];
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
    self.stationImage.hidden=YES;
    self.radarImage.hidden=NO;
    self.circlesImage.hidden=YES;
    for(UIView *deviceView in self.devicesScrollView.subviews)
    {
        [deviceView removeFromSuperview];
    }
    
    //start scan
    [self.foundPeripherals removeAllObjects];
    
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
    if(self.foundPeripherals.count==0)
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
    NSLog(@"ad:%@", advertisementData.description);
    
    if([peripheral.name isEqualToString:kScooterStationName])//station
    {
        self.stationImage.hidden=NO;
    }
    else // scooter
    {
        [self.foundPeripherals addObject:peripheral];
        
        NSString *name = advertisementData[kCBAdvDataLocalName];
        NSDictionary *serviceData=advertisementData[kCBAdvDataServiceData];
        CBUUID* batteryUUID=[CBUUID UUIDWithString:kBatteryServiceUUID];
        NSData* batteryData= serviceData[batteryUUID];
        
        [self addDeviceSite:peripheral localName:name battery:batteryData];
    }
}

#pragma - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x/self.view.frame.size.width;
}

#pragma - utilities

-(void)addDeviceSite:(CBPeripheral *)peripheral localName:(NSString *)localName battery:(NSData *)batteryData
{
    NSUInteger row = [self.foundPeripherals indexOfObject:peripheral];
    NSInteger numOfPages=(NSInteger)ceil((float)(row+1)/CountPerPage);
    
    self.foundView.hidden=NO;
    
    //set pageControl
    self.pageControl.hidden=row<CountPerPage;
    self.pageControl.currentPage=0;
    self.pageControl.numberOfPages=numOfPages;
    
    //set scroll view
    [self.devicesScrollView setContentSize:CGSizeMake(self.view.frame.size.width*numOfPages, self.view.frame.size.height)];
    
    //Add Device
    NSInteger indexInPage=row%CountPerPage;
    UIView *deviceView=[[[NSBundle mainBundle] loadNibNamed:@"spgDeviceSite" owner:self options:nil] objectAtIndex:0];
    deviceView.tag=row;
    deviceView.frame=CGRectMake((numOfPages-1)* self.view.frame.size.width+positions[indexInPage].x, positions[indexInPage].y, deviceView.frame.size.width, deviceView.frame.size.height);
    
    UILabel *name=(UILabel *)[deviceView viewWithTag:11];
    name.text=localName;
    
    UIButton *button=(UIButton *)[deviceView viewWithTag:12];
    button.imageView.image=[UIImage imageNamed:[self getScooterImageFromName:localName]];
    [button addTarget:self action:@selector(scooterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    float battery=[spgMScooterUtilities castBatteryToPercent:batteryData];
    UILabel *batteryLabel=(UILabel *)[deviceView viewWithTag:13];
    batteryLabel.text=[NSString stringWithFormat:@"%0.f%%",battery];
    
    [self.devicesScrollView addSubview:deviceView];
}

-(void)createPositions
{
    positions[0]= CGPointMake(45, 65);;
    
    positions[1]= CGPointMake(185, 310);
    positions[2]= CGPointMake(55, 350);
    positions[3]= CGPointMake(10, 180);
    positions[4]= CGPointMake(190, 125);
}

-(NSString *)getScooterImageFromName:(NSString *)name
{
    if([name hasPrefix:@"S_"])
    {
        return @"scooterTypeA.png";
    }
    else if([name hasPrefix:@"M_"])
    {
        return @"scooterTypeB.png";
    }
    else if([name hasPrefix:@"L_"])
    {
        return @"scooterTypeC.png";
    }
    else//default image
    {
        return @"scooterTypeA.png";
    }
}

@end
