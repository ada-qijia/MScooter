//
//  spgConnectViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/22/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgConnectViewController.h"
#import "spgTabBarViewController.h"
#import "spgScanViewController.h"

@interface spgConnectViewController ()

@property (weak,nonatomic) spgBLEService *bleService;

@end

@implementation spgConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=BackgroundImageColor;
    
    //set top left button
    NSString *myPeripheralID=[spgMScooterUtilities getMyPeripheralID];
    self.backButton.hidden=myPeripheralID;
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
    // Dispose of any resources that can be recreated.
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

- (IBAction)unlockClicked:(UIButton *)sender {
    [self login:nil];
}

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeClicked:(UIButton *)sender {
    [self.bleService disConnectPeripheral];
    
    [self navigateToNextPage];
    /*
    spgScanViewController *scanVC=(spgScanViewController *)self.presentingViewController;
    scanVC.shouldRetry=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
     */
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
    
    //show the unlock
    [self performSelector:@selector(showUnlock:) withObject:[NSNumber numberWithFloat:0.5] afterDelay:1];
    [self performSelector:@selector(twinkleUnlock:) withObject:nil afterDelay:1.5];
}

-(void)passwordCertificationReturned:(BOOL)correct
{
    if(correct)
    {
        [self navigateToNextPage];
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

-(void)navigateToNextPage
{
    //navigate to next page
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    spgTabBarViewController *tabBarVC=[storyboard instantiateViewControllerWithIdentifier:@"spgTabBarControllerID"];
        
    [self presentViewController:tabBarVC animated:YES completion:nil];
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
    //remove all animations
    [self resetUI];
    
    //fade in the car
    if(self.isPeripheralKnown)
    {
        [self fadeInScooterOutline:0.5];
        [self performSelector:@selector(fadeInScooterEntity:) withObject:[NSNumber numberWithFloat:0.5] afterDelay:0.5];
    }
    else //slide in the car
    {
        [self slideInScooter:1];
    }
    
    //show the iphone
    [self slideInPhone:1];
}

-(void)slideInScooter:(float)duration
{
    self.scooterOutline.hidden=NO;

    CABasicAnimation* slideFromLeft1 = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    slideFromLeft1.fromValue = [NSNumber numberWithFloat:-self.scooterOutline.bounds.size.width*0.7];
    slideFromLeft1.toValue = [NSNumber numberWithFloat:0];
    
    CABasicAnimation* fadeIn1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn1.fromValue = [NSNumber numberWithFloat:0.3];
    fadeIn1.toValue = [NSNumber numberWithFloat:1.0];

    CAAnimationGroup *group1=[CAAnimationGroup animation];
    group1.animations=@[slideFromLeft1,fadeIn1];
    group1.duration=duration;
    
    [self.scooterOutline.layer addAnimation:group1 forKey:@"outlineShow"];

    self.scooterEntity.hidden=NO;
    
    CABasicAnimation* slideFromLeft2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    slideFromLeft2.fromValue = slideFromLeft1.fromValue;
    slideFromLeft2.toValue = slideFromLeft1.toValue;
    
    CABasicAnimation* fadeIn2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn2.fromValue = [NSNumber numberWithFloat:0.3];
    fadeIn2.toValue = [NSNumber numberWithFloat:1.0];

    CAAnimationGroup *group2=[CAAnimationGroup animation];
    group2.animations=@[slideFromLeft2, fadeIn2];
    group2.duration=duration;
    
    [self.scooterEntity.layer addAnimation:group2 forKey:@"entitySlideIn"];
}

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
    CABasicAnimation* twinkle = [CABasicAnimation animationWithKeyPath:@"opacity"];
    twinkle.fromValue = [NSNumber numberWithFloat:0.5];
    twinkle.toValue = [NSNumber numberWithFloat:1.0];
    twinkle.duration = duration?duration.floatValue:0.5;
    twinkle.autoreverses=YES;
    twinkle.repeatCount=HUGE_VALF;
    [self.unlockHalo.layer addAnimation:twinkle forKey:@"opacity"];
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
    NSArray *viewsMayChanged=@[self.scooterOutline,self.scooterEntity,self.unlockHalo,self.unlockButton,self.phone];
    for (UIView * viewMayChanged in viewsMayChanged ){
        viewMayChanged.hidden=YES;
        [viewMayChanged.layer removeAllAnimations];
    }
}

@end

