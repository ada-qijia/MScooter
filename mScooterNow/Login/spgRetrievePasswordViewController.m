//
//  spgRetrievePasswordViewController.m
//  mScooterNow
//
//  Created by v-qijia on 5/11/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgRetrievePasswordViewController.h"
#import "spgMScooterCommon.h"

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>

#import "spgAlertView.h"
#import "spgUITextField.h"
#import "spgAlertViewManager.h"

@interface spgRetrievePasswordViewController ()

@end

@implementation spgRetrievePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTextFieldsUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - retrieve password

- (IBAction)fetchCheckcode:(id)sender {
    [self.view endEditing:YES];
    self.errorLabel.hidden=YES;
    
    if (![spgMScooterUtilities isValidMobile:self.phoneTextField.text])
    {
        //手机号码不正确
        self.errorLabel.text=@"Please enter valid phone number!";
        self.errorLabel.hidden=NO;
        return;
    }
    
    //发送验证码
    [SMS_SDK getVerificationCodeBySMSWithPhone:self.phoneTextField.text zone:@"86" result:^(SMS_SDKError *error)
     {
         if (!error)
         {
             self.errorLabel.text=@"Send verify code success!";
             self.errorLabel.hidden=NO;
         }
         else
         {
             self.errorLabel.text=@"Verify code send failed, Please retry!";
             self.errorLabel.hidden=NO;
         }
     }];
}

//验证验证码,如果成功，重置密码
- (IBAction)nextClicked:(id)sender {
    //验证，提示格式错误
    NSString *errorMessage;
    if(![spgMScooterUtilities isValidMobile:self.phoneTextField.text])
    {
        errorMessage= @"Please enter valid phone number!";
    }
    else if(self.checkcodeTextField.text.length ==0)
    {
        errorMessage= @"Please enter verify code!";
    }
    
    if(errorMessage)
    {
        self.errorLabel.text=errorMessage;
        self.errorLabel.hidden=NO;
        return;
    }
    else
    {
        self.errorLabel.hidden=YES;
    }

    //验证验证码
    [SMS_SDK commitVerifyCode:self.checkcodeTextField.text result:^(enum SMS_ResponseState state) {
        if (1==state)
        {
            //显示重置密码
            [self showResetView];
            self.errorLabel.hidden=YES;
        }
        else if(0==state)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.errorLabel.text=@"verify code wrong!";
                self.errorLabel.hidden=NO;
            });
        }
    }];
}

#pragma mark - reset password

//重置密码
- (IBAction)resetPassword:(id)sender {
    
    NSString *errorMessage;
    
    if(!self.passwordTextField.text.length)
    {
        errorMessage= @"Please enter passcode!";
    }
    else if(!self.confirmPasswordTextField.text.length)
    {
        errorMessage= @"Please reenter passcode!";
    }
    else if(![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text])
    {
        errorMessage= @"Please enter the same passcode!";
    }
    
    if(errorMessage)
    {
        self.errorLabel.text=errorMessage;
        self.errorLabel.hidden=NO;
    }
    else
    {
        //发送到服务器
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:self.phoneTextField.text,@"Phone",self.passwordTextField.text,@"Password",nil];
        NSError *error;
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:userInfo options:kNilOptions error:&error];
        if(error==nil)
        {
            //url request
            NSString *path=[NSString stringWithFormat:@"%@/ResetPassword",kServerUrlBase];
            NSURL *url=[NSURL URLWithString:path];
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:jsonData];
            [urlRequest addValue:@"application/json"forHTTPHeaderField:@"Content-Type"];
            
            NSURLSession *sharedSession=[NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask=[sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(error==nil)
                {
                    NSString *text=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"Data= %@", text);
                    
                    if([text integerValue]>0)
                    {
                        //使用alert提示
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:YES completion:nil];
                            
                            NSArray *buttons=[NSArray arrayWithObjects:@"OK", nil];
                            spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:@"reset passcode success. please login with your new passcode." buttons:buttons afterDismiss:^(NSString* passcode, int buttonIndex) {
                                /*if(buttonIndex==0)
                                 {
                                 [self dismissViewControllerAnimated:NO completion:nil];
                                 }*/
                            }];
                            [[spgAlertViewManager sharedAlertViewManager] show:alert];
                        });
                        return;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.errorLabel.text=@"reset passcode failed!";
                    self.errorLabel.hidden=NO;});
            }];
            
            [dataTask resume];
        }
        else
        {
            NSLog(@"Parse param to json error: %@",error.description);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - alert delegate



#pragma mark - common interaction

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//设置控件样式
-(void)setTextFieldsUI
{
    spgUITextField *phoneTF=(spgUITextField *)self.phoneTextField;
    [phoneTF setLeftImageView:@"mobileIcon.png"];
    [phoneTF setRightButtonView:self.verifyButton];
    
    [(spgUITextField *)self.checkcodeTextField setLeftImageView:@"verificationcodeIcon.png"];
    
    [(spgUITextField *)self.passwordTextField setLeftImageView:@"passcodeIcon.png"];
    [(spgUITextField *)self.confirmPasswordTextField setLeftImageView:@"passcodeIcon.png"];
    
    self.finishButton.layer.cornerRadius=5;
    self.finishButton.layer.masksToBounds=YES;
}

-(void)showResetView
{
    CATransition *transition=[CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    transition.subtype = kCATransitionFromRight;
    
    [self.retrieveView.layer addAnimation:transition forKey:nil];
    [self.resetView.layer addAnimation:transition forKey:nil];
    
    self.retrieveView.hidden=YES;
    self.resetView.hidden=NO;
}
@end
