//
//  spgLoginViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/21/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgLoginViewController.h"
#import "spgTabBarViewController.h"
#import "spgMScooterCommon.h"

@interface spgLoginViewController ()

@end

@implementation spgLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGradient.jpg"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma - UI interaction

- (IBAction)loginClicked:(UIButton *)sender {
    [spgMScooterUtilities savePreferenceWithKey:kUserKey value:@"N LeiLei"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backClicked:(UIButton *)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
@end
