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
#import "spgScanViewController.h"
#import "spgIntroductionViewController.h"
#import "spgAlertViewManager.h"

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
    
    BOOL isPasswordOn=[[spgMScooterUtilities getPreferenceWithKey:kPasswordOnKey] isEqualToString:@"YES"];
    
    self.PasswordOnSwitch.on=isPasswordOn;
    
    self.PasswordOnSwitch.enabled=[[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey] isEqualToString:kScenarioModePersonal];
}

#pragma - UI interaction

- (IBAction)ModeSettingClicked:(id)sender {
    spgModeSettingsViewController *modeSettingsVC=[[spgModeSettingsViewController alloc] initWithNibName:@"spgModeSettingsViewController" bundle:nil];
    [self presentViewController:modeSettingsVC animated:YES completion:nil];
}

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
            [spgMScooterUtilities savePreferenceWithKey:kMyPeripheralIDKey value:nil];
            
            //navigate to scan page
            spgScanViewController *scanVC=[[spgScanViewController alloc] initWithNibName:@"spgScan" bundle:nil];
            [self presentViewController:scanVC animated:YES completion:nil];
            
        }
    }];
    [[spgAlertViewManager sharedAlertViewManager] show:alert];
}

- (IBAction)PasswordSwitchChanged:(UISwitch *)sender {
    NSString *isOn=sender.isOn?@"YES":@"NO";
    [spgMScooterUtilities savePreferenceWithKey:kPasswordOnKey value:isOn];
    [spgMScooterUtilities savePreferenceWithKey:kAutoReconnectUUIDKey value:nil];
}

@end
