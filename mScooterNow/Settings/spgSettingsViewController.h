//
//  spgSettingsViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgSettingsViewController : UIViewController<UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *PowerAlwaysOnSwitch;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)AboutClicked:(UIButton *)sender;

- (IBAction)resetScooterClicked:(UIButton *)sender;
- (IBAction)PowerAlwaysOnSwitchChanged:(UISwitch *)sender;
- (IBAction)LoginClicked:(UIButton *)sender;
- (IBAction)ProfileClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *PowerAlwaysOnView;
@property (weak, nonatomic) IBOutlet UIView *AboutView;
@property (weak, nonatomic) IBOutlet UIButton *ResetButton;
@property (weak, nonatomic) IBOutlet UIView *profileView;

-(void)updateSwitch;

@end
