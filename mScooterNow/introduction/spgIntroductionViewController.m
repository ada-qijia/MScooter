//
//  spgIntroductionViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/20/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgIntroductionViewController.h"
#import "spgIntroductionPanel.h"
#import "spgIntroductionView.h"
#import "spgLoginViewController.h"

@interface spgIntroductionViewController ()

@end

@implementation spgIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildIntroduction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma - build spgIntroduction

-(void)buildIntroduction
{
    CGRect fullFrame= CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UIView *contentView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scooterEntity.png"]];
    contentView.frame=CGRectMake(0, 0, 250, 300);
    
    UIView *contentView2=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scooterOutline.png"]];
     contentView2.frame=CGRectMake(0, 0, 250, 300);
    
    spgIntroductionPanel *panel1=[spgIntroductionPanel introductionPanel];
    [panel1 buildWithContents:contentView description:@"Use your phone to Power on/Power off your scooter"];
    
    spgIntroductionPanel *panel2=[spgIntroductionPanel introductionPanel];
    [panel2 buildWithContents:contentView2 description:@"Manage your scooter data"];
    
    spgIntroductionPanel *panel3=[spgIntroductionPanel introductionPanel];
    [panel3 buildWithContents:contentView2 description:@"Augmented Reality Video Experience"];
    
    
    NSArray *panels=@[panel1,panel2,panel3];
    
    spgIntroductionView *introductionView = [[spgIntroductionView alloc] initWithFrame:fullFrame];
    introductionView.delegate=self;
    introductionView.BackgroundImageView.image=[UIImage imageNamed:@"bg2.jpg"];
    introductionView.buttonClicked=^(UIButton * sender)
    {
        [self footerButtonClicked:sender];
    };
    
    [introductionView buildIntroductionWithPanels:panels];
    
    [self.view addSubview:introductionView];
}

-(void)footerButtonClicked:(UIButton *)sender
{
    //navigate
    spgLoginViewController *loginVC=[[spgLoginViewController alloc] initWithNibName:@"spgLoginViewController" bundle:nil];
    loginVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:loginVC animated:YES completion:^{
        [self removeFromParentViewController];
    }];
}

#pragma - spgIntroduction Delegate

-(void)introduction:(spgIntroductionView *)introductionView didChangeToPanel:(spgIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %d", (int)panelIndex);
    
    if(panelIndex==2)
    {
        [introductionView setBottomButtonHidden:NO title:@"Join M-Scooter Now"];
    }
    else
    {
        [introductionView setBottomButtonHidden:YES title:nil];
    }
}

@end