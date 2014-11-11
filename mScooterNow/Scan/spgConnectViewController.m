//
//  spgConnectViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/22/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgConnectViewController.h"
#import "spgScanViewController.h"

@interface spgConnectViewController ()

@property (weak,nonatomic) spgBLEService *bleService;

@end

@implementation spgConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=BackgroundImageColor;
    
    //set top left button
    NSString *myPeripheralID=[spgMScooterUtilities getPreferenceWithKey:kMyPeripheralIDKey];
    self.backButton.hidden=(myPeripheralID!=nil);
    self.closeButton.hidden=!myPeripheralID;
    
    self.bleService=[spgBLEService sharedInstance];
    if(self.bleService && self.bleService.peripheral)
    {
        self.scooterName.text=self.bleService.peripheral.name;
        
        [self showConnectAnimation];
        [self performSelector:@selector(connect) withObject:nil afterDelay:1.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bleService.peripheralDelegate=self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.bleService.peripheralDelegate=nil;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma - UI interaction

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeClicked:(UIButton *)sender {
    [self.bleService disConnectPeripheral];
    
    [self backToTabBarViewController];
}

#pragma - ble operation

-(void)connect
{
    [self.bleService connectPeripheral];
    //show the connect animation
    [self loopConnect];
}

#pragma - spgBLEServicePeripheralDelegate

-(void)centralManager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral
{
    //stop loop connect animation
    [self.connectionImage.layer removeAllAnimations];
    
    [self login:nil];
}

-(void)passwordCertificationReturned:(CBPeripheral *)peripheral result:(BOOL) correct
{
    if(correct)
    {
        //save peripheral UUID if success and in personal mode.
        BOOL isPersonal=[[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey] isEqualToString:kScenarioModePersonal];
        if(isPersonal)
        {
            [spgMScooterUtilities savePreferenceWithKey:kMyPeripheralIDKey value:[peripheral.identifier UUIDString]];
        }
        
        [self backToTabBarViewController];
    }
    else
    {
        self.powerOnView.hidden=YES;
        [self.powerOnCircleImage.layer removeAllAnimations];
        
        [self incorrectPinEnteredInPinViewController:nil];
        [self login:nil];
    }
}

#pragma mark - pin delegate

-(void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController
{
    //self.correctPin
    [self.bleService writePassword:[self getDataFromPin]];
    
    //show power on animation
    self.connectionView.hidden=YES;
    
    [self RotatePowerOn];
}

#pragma - utilities

-(void)backToTabBarViewController
{
    UIViewController *currentVC=self;
    while (currentVC && ![currentVC isKindOfClass:[UITabBarController class]]) {
        [currentVC dismissViewControllerAnimated:NO completion:nil];
        currentVC=currentVC.presentingViewController;
    }
}

-(NSData *)getDataFromPin
{
    if(self.currentPin)
    {
        Byte byte0=[[self.currentPin substringToIndex:2] intValue];
        Byte byte1=[[self.currentPin substringFromIndex:2] intValue];
        Byte array[]={byte0,byte1};
        NSData *pinData=[NSData dataWithBytes:array length:2];
        return pinData;
    }
    else
    {
        return nil;
    }
}

#pragma mark - scooter animation

-(void)showConnectAnimation
{
    /*
    //remove all animations
    [self resetUI];
     [self slideInScooter:1];
    //show the iphone
    [self slideInPhone:1];
     */
}

-(void)slideInScooter:(float)duration
{
    self.scooterEntity.hidden=NO;
    
    CABasicAnimation* slideFromLeft2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    //slideFromLeft2.fromValue = slideFromLeft1.fromValue;
    //slideFromLeft2.toValue = slideFromLeft1.toValue;
    
    CABasicAnimation* fadeIn2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn2.fromValue = [NSNumber numberWithFloat:0.3];
    fadeIn2.toValue = [NSNumber numberWithFloat:1.0];

    CAAnimationGroup *group2=[CAAnimationGroup animation];
    group2.animations=@[slideFromLeft2, fadeIn2];
    group2.duration=duration;
    
    [self.scooterEntity.layer addAnimation:group2 forKey:@"entitySlideIn"];
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

-(void)slideInPhone:(float)duration
{
    self.phone.hidden= NO;
    
    CABasicAnimation* slideFromRight= [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    slideFromRight.fromValue = [NSNumber numberWithFloat:self.phone.bounds.size.width*0.7];
    slideFromRight.toValue = [NSNumber numberWithFloat:0];
    slideFromRight.duration=duration;
    
    [self.phone.layer addAnimation:slideFromRight forKey:@"phoneShow"];
}

-(void)loopConnect
{
    self.connectionImage.hidden=NO;
    CABasicAnimation* fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = [NSNumber numberWithFloat:0];
    fadeIn.toValue = [NSNumber numberWithFloat:1.0];
    fadeIn.duration = 0.5;
    fadeIn.autoreverses=YES;
    fadeIn.repeatCount=HUGE_VALF;
    
    [self.connectionImage.layer addAnimation:fadeIn forKey:@"connectionLoop"];
}

-(void)RotatePowerOn
{
    self.powerOnView.hidden=NO;
    
    CABasicAnimation *rotationAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.repeatCount=HUGE_VALF;
    rotationAnimation.byValue=[NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration=2;
    rotationAnimation.cumulative=YES;

    [self.powerOnCircleImage.layer addAnimation:rotationAnimation forKey:@"powerOnRotate"];
}

-(void)resetUI
{
    NSArray *viewsMayChanged=@[self.scooterEntity,self.phone];
    for (UIView * viewMayChanged in viewsMayChanged ){
        viewMayChanged.hidden=YES;
        [viewMayChanged.layer removeAllAnimations];
    }
}

@end

