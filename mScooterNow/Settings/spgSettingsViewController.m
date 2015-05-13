
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
    else
    {
        imgView.image=[UIImage imageNamed:@"me.png"];
        nameLabel.text=@"Join Us";
    }
    
    self.loginButton.hidden=userInfo;
    self.logoutButton.hidden=!userInfo;
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
            spgTabBarViewController *tabbarVC=(spgTabBarViewController *)self.parentViewController;
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
    [self addChildViewController:loginVC];
    [self.view addSubview:loginVC.view];
    
}

- (IBAction)LogoutClicked:(UIButton *)sender {
    [spgMScooterUtilities setUserID:0];
    bool success = [spgMScooterUtilities saveToFile:kUserInfoFilename data:[NSData data]];
    NSLog(@"clear login info %@",success?@"successfully":@"failed");
    [self updateUserInfo];
}

@end
