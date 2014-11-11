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

@interface spgSettingsViewController ()

@end

@implementation spgSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - UI interaction

- (IBAction)ModeSettingClicked:(id)sender {
    spgModeSettingsViewController *modeSettingsVC=[[spgModeSettingsViewController alloc] initWithNibName:@"spgModeSettingsViewController" bundle:nil];
    [self presentViewController:modeSettingsVC animated:YES completion:nil];
}

- (IBAction)changePasswordClicked:(UIButton *)sender {
    spgChangePasswordViewController *changePasswordVC=[[spgChangePasswordViewController alloc] initWithNibName:@"spgChangePasswordViewController" bundle:nil];
    [self presentViewController:changePasswordVC animated:YES completion:nil];
}

- (IBAction)AboutClicked:(UIButton *)sender {
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    spgIntroductionViewController *introductionVC=[storyboard instantiateViewControllerWithIdentifier:@"spgIntroductionVCID"];
    introductionVC.isRelay=NO;
    
    [self presentViewController:introductionVC animated:YES completion:nil];
}

- (IBAction)resetScooterClicked:(UIButton *)sender {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Are you sure to reset a new scooter?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
    [alert show];
}

#pragma - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        //clean saved MyPeripheralID if change to personal mode.
        [spgMScooterUtilities savePreferenceWithKey:kMyPeripheralIDKey value:nil];
        
        //navigate to scan page
        spgScanViewController *scanVC=[[spgScanViewController alloc] initWithNibName:@"spgScan" bundle:nil];
        
        [self presentViewController:scanVC animated:NO completion:nil];
    }
}

@end
