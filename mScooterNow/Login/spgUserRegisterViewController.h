//
//  spgUserRegisterViewController.h
//  mScooterNow
//
//  Created by v-qijia on 4/9/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryCodeViewController.h"

@interface spgUserRegisterViewController : UIViewController<CountryCodeViewControllerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *ChooseCountryButton;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UITextField *passcodeField;
@property (weak, nonatomic) IBOutlet UIButton *viewPasscodeButton;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

- (IBAction)HidePasscode:(id)sender;
- (IBAction)showPasscode:(id)sender;
- (IBAction)ChooseCountryClick:(id)sender;
- (IBAction)submitClick:(id)sender;
- (IBAction)avatarClick:(id)sender;

@property (weak,nonatomic) UIViewController * LoginVC;
@property (weak, nonatomic) IBOutlet UIView *optionalInfoView;


@end
