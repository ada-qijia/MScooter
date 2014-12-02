//
//  spgSettingsViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *PasswordOnSwitch;

- (IBAction)ModeSettingClicked:(id)sender;
//- (IBAction)changePasswordClicked:(UIButton *)sender;
- (IBAction)AboutClicked:(UIButton *)sender;

- (IBAction)resetScooterClicked:(UIButton *)sender;
- (IBAction)PasswordSwitchChanged:(UISwitch *)sender;

@end
