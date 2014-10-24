//
//  spgScanViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgScanViewController.h"

static NSString *const SCOOTER_SERVICE_UUID=@"4B4681A4-1246-1EEC-AB2B-FE45F896822D";
static const NSInteger CountPerPage = 1;
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
        self.bleService=[[spgBLEService alloc]initWithDelegates:self peripheralDelegate:nil];
    }
    //return back
    else if(self.shouldRetry)
    {
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
    for(UIView *deviceView in self.devicesScrollView.subviews)
    {
        [deviceView removeFromSuperview];
    }

    self.foundView.hidden=YES;
    self.notFoundView.hidden=YES;
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
    [self.foundPeripherals removeAllObjects];
  
    if(!isScanning && self.bleService.centralManager.state==CBCentralManagerStatePoweredOn)
    {
        //start a timer
        scanTimer=[NSTimer scheduledTimerWithTimeInterval:ScanInterval target:self selector:@selector(timerElapsed) userInfo:nil repeats:NO];

        //run animation
        [self startSpin];
        
        //find known peripheral
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        NSString *idString= [userDefaults stringForKey:kMyPeripheralIDKey];
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
    if(isScanning)
    {
        isScanning=NO;
        [self.bleService stopScan];
        [self stopSpin];
    
        self.retryButton.enabled=YES;
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
    self.radarImage.alpha = 1.0;
    
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
    self.radarImage.alpha=0.5;
    
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
    destination.bleService=self.bleService;
    destination.isPeripheralKnown=isKnown;
    if(self.foundPeripherals.count>index)
    {
        destination.peripheral=self.foundPeripherals[index];
    }
    
    //destination.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:destination animated:NO completion:nil];
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
    [self.foundPeripherals addObject:peripheral];
    [self addDeviceSite:peripheral];
}

#pragma - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x/self.view.frame.size.width;
}

#pragma - utilities

-(void)addDeviceSite:(CBPeripheral *)peripheral
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
        name.text=peripheral.name;
        UIButton *button=(UIButton *)[deviceView viewWithTag:12];
        button.layer.borderColor=[ThemeColor CGColor];
        [button addTarget:self action:@selector(scooterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
        [self.devicesScrollView addSubview:deviceView];
}

-(void)createPositions
{
    positions[0]= CGPointMake(30, 90);;
   
    /*positions[1]= CGPointMake(130, 270);
    positions[2]= CGPointMake(45, 190);
    positions[3]= CGPointMake(230, 285);
    positions[4]= CGPointMake(100, 15);*/
}

@end
