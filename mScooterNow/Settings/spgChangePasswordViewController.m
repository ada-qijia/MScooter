//
//  spgChangePasswordViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/20/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgChangePasswordViewController.h"

@interface spgChangePasswordViewController ()

@end

@implementation spgChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
