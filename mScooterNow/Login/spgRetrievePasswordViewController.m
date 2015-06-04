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

#import "spgSMSVerifyViewController.h"

@interface spgRetrievePasswordViewController ()
{
    spgSMSVerifyViewController *verifyVC;
    NSString* phone;
}
@end

@implementation spgRetrievePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"";
    
    [self AddVerifyView];
    [self setTextFieldsUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//close the keyborad
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - retrieve password

-(void)AddVerifyView
{
    __weak typeof(self) weakSelf = self;
    verifyVC=[[spgSMSVerifyViewController alloc] initWithSubtitle:nil];
    verifyVC.dismissBlock=^(NSString *phoneNumber){
        phone = phoneNumber;
        [weakSelf showResetView];
    };
    verifyVC.notifyBlock=^(NSString *message){
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.errorLabel.text=message;
            weakSelf.errorLabel.hidden=!(message.length>0);
        });
    };
    
    verifyVC.view.frame=CGRectMake(0, 30, 320, 270);
    [self.retrieveView addSubview:verifyVC.view];
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
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:phone,@"Phone",self.passwordTextField.text,@"NewPassword",nil];
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
            
            [self setActivityIndicatorVisibility:YES];
            NSURLSession *sharedSession=[NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask=[sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setActivityIndicatorVisibility:NO];
                });
                NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
                if(httpResponse.statusCode==200 && error==nil)
                {
                    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSLog(@"Data= %@", json);
                    NSInteger errorCode=[[json objectForKey:@"ErrorCode"] integerValue];
                    if(errorCode==0)
                    {
                        //退回上一页
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSArray *buttons=[NSArray arrayWithObjects:@"OK", nil];
                            spgAlertView *alert=[[spgAlertView alloc] initWithTitle:nil message:@"reset passcode success. please login with your new passcode." buttons:buttons afterDismiss:^(NSString* passcode, int buttonIndex) {
                                [self back];
                            }];
                            [[spgAlertViewManager sharedAlertViewManager] show:alert];

                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.errorLabel.text=[json objectForKey:@"ErrorMessage"];
                            self.errorLabel.hidden=NO;
                        });
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.errorLabel.text=@"reset passcode failed!";
                        self.errorLabel.hidden=NO;});
                }
            }];
            
            [dataTask resume];
        }
        else
        {
            NSLog(@"Parse param to json error: %@",error.description);
            [self back];
        }
    }
}

- (IBAction)confirmPasscodeChanged:(id)sender
{
    [self updateFinishState];
}

- (IBAction)passcodeChanged:(id)sender
{
    [self updateFinishState];
}


#pragma mark - common interaction

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

//设置控件样式
-(void)setTextFieldsUI
{
    [(spgUITextField *)self.passwordTextField setLeftImageView:@"passcodeIcon.png"];
    [(spgUITextField *)self.confirmPasswordTextField setLeftImageView:@"passcodeIcon.png"];
    
    [self updateFinishState];
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

//设置按钮样式
-(void)setGrayButtonState:(UIButton *)button enabled:(BOOL)enabled
{
    button.enabled = enabled;
    button.backgroundColor = enabled? ThemeColor:[UIColor grayColor];
}

//设置完成按钮状态
-(void)updateFinishState
{
    BOOL btnEnabled=self.passwordTextField.text.length>0 && self.confirmPasswordTextField.text.length>0;
    [self setGrayButtonState:self.finishButton enabled:btnEnabled];
}

-(void)setActivityIndicatorVisibility:(BOOL) visible
{
    UIActivityIndicatorView *activityIndicator=(UIActivityIndicatorView *)[self.view viewWithTag:1000];
    if(visible)
    {
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicator stopAnimating];
    }
}
@end
