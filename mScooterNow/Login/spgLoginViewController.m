//
//  spgLoginViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/21/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgLoginViewController.h"
#import "spgScanViewController.h"

@interface spgLoginViewController ()

@end

@implementation spgLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.jpg"]]];
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
    [self navigateToScan];
}

- (IBAction)skipClicked:(UIButton *)sender {
    [self navigateToScan];
}

-(void)navigateToScan
{
    spgScanViewController *scanVC=[[spgScanViewController alloc] initWithNibName:@"spgScan" bundle:nil];
  
    [self presentViewController:scanVC animated:NO completion:^{
         [self removeFromParentViewController];
    }];
}

@end
