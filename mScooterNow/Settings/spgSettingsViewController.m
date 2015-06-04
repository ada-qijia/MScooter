
//
//  spgSettingsViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgSettingsViewController.h"
#import "spgChangePasswordViewController.h"
#import "spgTabBarViewController.h"
#import "spgIntroductionViewController.h"
#import "spgAlertViewManager.h"
#import "spgLoginViewController.h"
#import "spgMyProfileViewController.h"

@interface spgSettingsViewController ()

@end

@implementation spgSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGradient.jpg"]];
    UIImageView *imgView=(UIImageView *) [self.view viewWithTag:100];
    imgView.layer.borderColor=ThemeColor.CGColor;
    
    //set navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.title=@"";
    
    self.navigationController.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateUserInfo];
    [self updateSwitch];
}

//设置用户名，头像
-(void)updateUserInfo
{
    UIImageView *imgView=(UIImageView *) [self.view viewWithTag:100];
    UILabel *nameLabel=(UILabel *) [self.view viewWithTag:200];
    
    NSData *jsonData=[spgMScooterUtilities readFromFile:kUserInfoFilename];
    NSDictionary *userInfo =jsonData?[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil]:nil;
    if(userInfo)
    {
        NSString *avatar=[userInfo objectForKey:@"Avatar"];
        if(![avatar isKindOfClass:[NSNull class]])
        {
            NSData *avatarData = [[NSData alloc]
                                  initWithBase64EncodedString:avatar options:0];
            UIImage *img=[UIImage imageWithData:avatarData];
            imgView.image=img;
        }
        
        NSString *nickname=[userInfo objectForKey:@"Nickname"];
        if(![nickname isKindOfClass:[NSNull class]])
        {
            nameLabel.text=nickname;
        }
    }
    
    self.profileView.hidden=!userInfo;
    self.loginButton.hidden=userInfo;
    //self.logoutButton.hidden=!userInfo;
}

-(void)updateSwitch
{
    NSInteger lastState = [[spgMScooterUtilities getPreferenceWithKey:kLastPowerStateKey] integerValue];
    self.PowerAlwaysOnSwitch.on=lastState==PowerAlwaysOn;
    
    NSNumber *scooterCertified=[spgBLEService sharedInstance].isCertified;
    BOOL isPowerModeChangable = [scooterCertified boolValue]==YES;
    self.PowerAlwaysOnView.hidden=!isPowerModeChangable;
    CGRect secondItemFrame=self.PowerAlwaysOnView.frame;
    secondItemFrame.origin.y=secondItemFrame.origin.y+secondItemFrame.size.height;
    self.AboutView.frame=isPowerModeChangable?secondItemFrame:self.PowerAlwaysOnView.frame;
    self.ResetButton.hidden=!isPowerModeChangable; //[spgBLEService sharedInstance].peripheral.state==CBPeripheralStateConnected;
}

#pragma mark - navigation delegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController==self)
    {
        [self viewWillAppear:animated];
    }
}

#pragma - UI interaction

- (IBAction)AboutClicked:(UIButton *)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    spgIntroductionViewController *introductionVC=[storyboard instantiateViewControllerWithIdentifier:@"spgIntroductionVCID"];
    introductionVC.isRelay=NO;
    
    //push from right
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self presentViewController:introductionVC animated:NO completion:nil];
}

- (IBAction)resetScooterClicked:(UIButton *)sender {
    NSArray *buttons=[NSArray arrayWithObjects:@"NO", @"YES",nil];
    spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:@"Are You Sure to Reset A New Scooter?" buttons:buttons afterDismiss:^(NSString* passcode, int buttonIndex) {
        if(buttonIndex==1)
        {
            [[spgBLEService sharedInstance] clean];
            
            //clean saved MyPeripheralID if change to personal mode.
            //[spgMScooterUtilities savePreferenceWithKey:kMyPeripheralIDKey value:nil];
            
            //navigate to dashboard page
            spgTabBarViewController *tabbarVC=(spgTabBarViewController *)self.parentViewController.parentViewController;
            [tabbarVC setSelectedTabIndex:1];
        }
    }];
    [[spgAlertViewManager sharedAlertViewManager] show:alert];
}

- (IBAction)PowerAlwaysOnSwitchChanged:(UISwitch *)sender {
    Byte mode=sender.isOn?PowerAlwaysOnCmd:PowerWithPhoneCmd;
    NSData *data=[spgMScooterUtilities getDataFromByte:mode];
    [[spgBLEService sharedInstance] writePower:data];
    
    /*
     //reset battery state
     spgTabBarViewController *tabBarVC=(spgTabBarViewController *)self.tabBarController;
     tabBarVC.currentBatteryState=BatteryStateWaitUpdate;*/
}

- (IBAction)LoginClicked:(UIButton *)sender {
    spgLoginViewController *loginVC=[[spgLoginViewController alloc] initWithNibName:@"spgLoginViewController" bundle:nil];
    //[self presentViewController:loginVC animated:YES completion:nil];
    //not use modal view to make sure third-party login work
    /*[self addChildViewController:loginVC];
     [self.view addSubview:loginVC.view];*/
    
    [self.navigationController pushViewController:loginVC animated:YES];
    
}

//goto detail page
- (IBAction)ProfileClicked:(id)sender {
    spgMyProfileViewController *profileVC=[[spgMyProfileViewController alloc] init];
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end
