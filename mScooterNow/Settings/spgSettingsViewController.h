//
//  spgSettingsViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *PowerAlwaysOnSwitch;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

- (IBAction)AboutClicked:(UIButton *)sender;

- (IBAction)resetScooterClicked:(UIButton *)sender;
- (IBAction)PowerAlwaysOnSwitchChanged:(UISwitch *)sender;
- (IBAction)LoginClicked:(UIButton *)sender;
- (IBAction)LogoutClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *PowerAlwaysOnView;
@property (weak, nonatomic) IBOutlet UIView *AboutView;

-(void)updateSwitch;

@end
