//
//  spgRetrievePasswordViewController.h
//  mScooterNow
//
//  Created by v-qijia on 5/11/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgRetrievePasswordViewController : UIViewController<UIAlertViewDelegate>

#pragma mark - common item

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


#pragma mark - retrieve password

@property (weak, nonatomic) IBOutlet UIView *retrieveView;

#pragma mark - reset password

@property (weak, nonatomic) IBOutlet UIView *resetView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

- (IBAction)confirmPasscodeChanged:(id)sender;
- (IBAction)passcodeChanged:(id)sender;

- (IBAction)resetPassword:(id)sender;

@end
