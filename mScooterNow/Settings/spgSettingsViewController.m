//
//  spgSettingsViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgSettingsViewController.h"
#import "spgChangePasswordViewController.h"
#import "spgScanViewController.h"

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

- (IBAction)changePasswordClicked:(UIButton *)sender {
    spgChangePasswordViewController *changePasswordVC=[[spgChangePasswordViewController alloc] initWithNibName:@"spgChangePasswordViewController" bundle:nil];
    [self presentViewController:changePasswordVC animated:YES completion:nil];
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
        [self backToScanViewController];
    }
}

-(void)backToScanViewController
{
    UIViewController *currentVC=self;
    while (currentVC && ![currentVC isKindOfClass:[spgScanViewController class]]) {
        [currentVC dismissViewControllerAnimated:NO completion:nil];
        currentVC=currentVC.presentingViewController;
    }
    
    if([currentVC isKindOfClass:[spgScanViewController class]])
    {
        spgScanViewController *scanVC=(spgScanViewController *)currentVC;
        scanVC.shouldRetry=YES;
    }
}

@end
