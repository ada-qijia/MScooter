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
#import "spgTabBarViewController.h"

@interface spgIntroductionViewController ()

@end

@implementation spgIntroductionViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isRelay=YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildIntroduction];
    
    self.backButton.hidden=self.isRelay;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma - build spgIntroduction

-(void)buildIntroduction
{
    CGRect fullFrame= CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UIView *contentView1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuide0.png"]];
    contentView1.frame=CGRectMake(0, 0, 320, 223);
    
    UIView *contentView2=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuide1.png"]];
     contentView2.frame=contentView1.frame;
    
    UIView *contentView3=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuide2.png"]];
    contentView3.frame=contentView1.frame;
    
    spgIntroductionPanel *panel1=[spgIntroductionPanel introductionPanel];
    [panel1 buildWithContents:contentView1 description:@"Use your phone to Power on/Power off your scooter"];
    
    spgIntroductionPanel *panel2=[spgIntroductionPanel introductionPanel];
    [panel2 buildWithContents:contentView2 description:@"Manage your scooter data"];
    
    spgIntroductionPanel *panel3=[spgIntroductionPanel introductionPanel];
    [panel3 buildWithContents:contentView3 description:@"Augmented Reality Video Experience"];
    
    
    NSArray *panels=@[panel1,panel2,panel3];
    
    spgIntroductionView *introductionView = [[spgIntroductionView alloc] initWithFrame:fullFrame];
    introductionView.delegate=self;
    introductionView.BackgroundImageView.image=[UIImage imageNamed:@"bgGradient.jpg"];
    introductionView.buttonClicked=^(UIButton * sender)
    {
        [self footerButtonClicked:sender];
    };
    
    [introductionView buildIntroductionWithPanels:panels];
    
    [self.view insertSubview:introductionView atIndex:0];
}

-(void)footerButtonClicked:(UIButton *)sender
{
    //save notFirstUse preference
    [spgMScooterUtilities savePreferenceWithKey:kNotFirstUseKey value:@"YES"];
    
    //navigate
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    spgTabBarViewController *tabBarVC=[storyboard instantiateViewControllerWithIdentifier:@"spgTabBarControllerID"];
    tabBarVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:tabBarVC animated:YES completion:^{
        [self removeFromParentViewController];
    }];
}

#pragma - spgIntroduction Delegate

-(void)introduction:(spgIntroductionView *)introductionView didChangeToPanel:(spgIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %d", (int)panelIndex);
    
    if(panelIndex==2 && self.isRelay)
    {
        [introductionView setBottomButtonHidden:NO title:@"Join Neezza Now"];
    }
    else
    {
        [introductionView setBottomButtonHidden:YES title:nil];
    }
}

#pragma - UI interaction

//close this view
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
