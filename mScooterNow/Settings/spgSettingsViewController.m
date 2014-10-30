//
//  spgSettingsViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgSettingsViewController.h"
#import "spgChangePasswordViewController.h"

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)changePasswordClicked:(UIButton *)sender {
    spgChangePasswordViewController *changePasswordVC=[[spgChangePasswordViewController alloc] initWithNibName:@"spgChangePasswordViewController" bundle:nil];
    [self presentViewController:changePasswordVC animated:YES completion:nil];
}
@end
