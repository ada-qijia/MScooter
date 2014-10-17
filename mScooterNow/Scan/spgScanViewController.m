//
//  spgScanViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgScanViewController.h"

static NSString *const SCOOTER_SERVICE_UUID=@"4B4681A4-1246-1EEC-AB2B-FE45F896822D";
static NSString *const SPEED_CHARACTERISTIC_UUID=@"";
static NSString *const POWER_CHARACTERISTIC_UUID=@"";

@interface spgScanViewController ()

@property (strong,nonatomic)spgBLEService *bleService;
@property (strong,nonatomic)CBPeripheral *foundPeripheral;

@end

@implementation spgScanViewController
{
    BOOL isPinning;
    BOOL isScanning;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self login:nil];
}

- (IBAction)retryClicked:(id)sender {
    
    self.scooterOutline.hidden=YES;
    self.scooterEntity.hidden=YES;
    self.unlockHalo.hidden=YES;
    self.unlockButton.hidden=YES;
    self.retryButton.enabled=NO;

    [self startScan];
}

#pragma - custom methods

-(BOOL)startScan
{
    self.foundPeripheral=nil;
  
    if(!isScanning && self.bleService.centralManager.state==CBCentralManagerStatePoweredOn)
    {   //run animation
        [self startSpin];
        
        [self.bleService startScan];
        
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
        [self removeAllAnimations];
    
        self.retryButton.enabled=YES;
    }
}

-(void)removeAllAnimations
{
    [self stopSpin];
    [self.scooterOutline.layer removeAllAnimations];
    [self.scooterEntity.layer removeAllAnimations];
    [self.unlockHalo.layer removeAllAnimations];
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
    self.circlesBg.hidden=YES;
    
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
    self.radarImage.alpha=0;
    self.circlesBg.hidden=NO;
    
    if(isPinning)
    {
        isPinning=NO;
        [self pauseSpinAnimation];
    }
}

#pragma mark - scooter animation

-(void)fadeInScooterOutline:(float)duration
{
    self.scooterOutline.hidden=NO;
    
    CABasicAnimation* fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.0];
    fadeIn.toValue = [NSNumber numberWithFloat:1.0];
    fadeIn.duration = duration;
    
    [self.scooterOutline.layer addAnimation:fadeIn forKey:@"opacity"];
}

-(void)fadeInScooterEntity:(NSNumber *)duration
{
    self.scooterEntity.hidden=NO;
    
    CABasicAnimation* fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.0];
    fadeIn.toValue = [NSNumber numberWithFloat:1.0];
    fadeIn.duration =duration? duration.floatValue: 1.5;

    [self.scooterEntity.layer addAnimation:fadeIn forKey:@"opacity"];
}

-(void)showUnlock:(NSNumber *)duration
{
    self.unlockHalo.hidden=NO;
    self.unlockButton.hidden=NO;
    
    float defaultDuration=1.0;
    CABasicAnimation* fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.3];
    fadeIn.toValue = [NSNumber numberWithFloat:1.0];
    
    CABasicAnimation* expand = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expand.fromValue = [NSNumber numberWithFloat:0.3];
    expand.toValue = [NSNumber numberWithFloat:1.0];
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:expand, nil];
    group.duration = duration?duration.floatValue:defaultDuration;
    
    [self.unlockHalo.layer addAnimation:group forKey:@"haloGroup"];
    [self.unlockButton.layer addAnimation:group forKey:@"unlockGroup"];
}

-(void)twinkleUnlock:(NSNumber *)duration
{
    [self stopScan];
    
    CABasicAnimation* twinkle = [CABasicAnimation animationWithKeyPath:@"opacity"];
    twinkle.fromValue = [NSNumber numberWithFloat:0.5];
    twinkle.toValue = [NSNumber numberWithFloat:1.0];
    twinkle.duration = duration?duration.floatValue:0.5;
    twinkle.autoreverses=YES;
    twinkle.repeatCount=HUGE_VALF;
    [self.unlockHalo.layer addAnimation:twinkle forKey:@"opacity"];
}

#pragma mark - segue navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITabBarController *tabBarController=segue.destinationViewController;
    spgDashboardViewController *destination=(spgDashboardViewController *)[tabBarController. viewControllers objectAtIndex:0];
    
    if(sender && destination)
    {
       destination.bleService=self.bleService;
       destination.peripheral=sender;
    }
}

#pragma mark - pin delegate

-(void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController
{
    self.locked=NO;
    [self performSegueWithIdentifier:@"ConnectPeripheral" sender:self.foundPeripheral];
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

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //[self stopScan];
    if(!self.foundPeripheral)
    {
        self.foundPeripheral=peripheral;
        [self fadeInScooterOutline:0.8];
        [self performSelector:@selector(fadeInScooterEntity:) withObject:[NSNumber numberWithFloat:1.2] afterDelay:0.8];
        
        [self performSelector:@selector(showUnlock:) withObject:[NSNumber numberWithFloat:0.5] afterDelay:2];
        [self performSelector:@selector(twinkleUnlock:) withObject:nil afterDelay:2.5];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
