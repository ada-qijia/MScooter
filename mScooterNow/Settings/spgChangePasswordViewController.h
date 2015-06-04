//
//  spgChangePasswordViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/20/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgChangePasswordViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *OldPasscodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *NewPasscodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *RenewPasscodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *ErrorLabel;
@property (weak, nonatomic) IBOutlet UIButton *OKButton;

- (IBAction)okClicked:(UIButton *)sender;

- (IBAction)passcodeChanged:(id)sender;

@end
