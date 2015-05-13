//
//  spgLoginViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/21/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spgThirdpartyLoginManager.h"

@interface spgLoginViewController : UIViewController <UITextFieldDelegate, WeiboLoginDelegate,WechatLoginDelegate>

- (IBAction)registerClick:(UIButton *)sender;
- (IBAction)loginClicked:(UIButton *)sender;
- (IBAction)backClicked:(UIButton *)sender;
- (IBAction)forgetPasscodeClick:(id)sender;

- (IBAction)weiboLogin:(UIButton *)sender;
- (IBAction)weixinLogin:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passcodeTextField;

@end
