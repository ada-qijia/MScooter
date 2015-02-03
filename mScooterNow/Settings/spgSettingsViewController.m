
//
//  spgSettingsViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgSettingsViewController.h"
#import "spgChangePasswordViewController.h"
#import "spgModeSettingsViewController.h"
#import "spgTabBarViewController.h"
#import "spgIntroductionViewController.h"
#import "spgAlertViewManager.h"
#import "spgLoginViewController.h"

@interface spgSettingsViewController ()

@end

@implementation spgSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGradient.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLoginUI];
    [self updateSwitch];
}

-(void)updateLoginUI
{
    NSString *user= [spgMScooterUtilities getPreferenceWithKey:kUserKey];
    //if user, login
    self.userInfoImage.hidden=!user;
    self.loginButton.hidden=user;
    self.logoutButton.hidden=!user;
    
    /*
     NSString *imgName=user?@"settingPortrait.png":@"me@2x.png";
     self.tabBarItem.image=[[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     self.tabBarItem.selectedImage=user?self.tabBarItem.image:[UIImage imageNamed:imgName];*/
}

-(void)updateSwitch
{
    NSInteger lastState = [[spgMScooterUtilities getPreferenceWithKey:kLastPowerStateKey] integerValue];
    self.PowerAlwaysOnSwitch.on=lastState==PowerAlwaysOn;
    
    NSNumber *scooterCertified=[spgBLEService sharedInstance].isCertified;
    BOOL isPowerModeChangable = [scooterCertified boolValue]==YES;
    self.PowerAlwaysOnView.hidden=!isPowerModeChangable;
    self.AboutView.frame=isPowerModeChangable?CGRectMake(0, 240, 320, 55):CGRectMake(0, 185, 320, 55);
}

#pragma - UI interaction

/*
 - (IBAction)changePasswordClicked:(UIButton *)sender {
 spgChangePasswordViewController *changePasswordVC=[[spgChangePasswordViewController alloc] initWithNibName:@"spgChangePasswordViewController" bundle:nil];
 [self presentViewController:changePasswordVC animated:YES completion:nil];
 }
 */

- (IBAction)AboutClicked:(UIButton *)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    spgIntroductionViewController *introductionVC=[storyboard instantiateViewControllerWithIdentifier:@"spgIntroductionVCID"];
    introductionVC.isRelay=NO;
    
    [self presentViewController:introductionVC animated:YES completion:nil];
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
            spgTabBarViewController *tabbarVC=(spgTabBarViewController *)self.tabBarController;
            tabbarVC.selectedIndex=1;
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
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (IBAction)LogoutClicked:(UIButton *)sender {
    [spgMScooterUtilities savePreferenceWithKey:kUserKey value:nil];
    [self updateLoginUI];
}

@end
