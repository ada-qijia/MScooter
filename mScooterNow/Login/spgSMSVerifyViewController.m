//
//  spgSMSVerifyViewController.m
//  mScooterNow
//
//  Created by v-qijia on 5/14/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgSMSVerifyViewController.h"
#import "spgMScooterCommon.h"
#import "spgUITextField.h"

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>

@interface spgSMSVerifyViewController ()
@end

@implementation spgSMSVerifyViewController
{
    NSString *subtitle;
    NSTimer *timer;
    int count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self InitializeUI];
    
    self.subTitleLabel.text=subtitle;
    self.subTitleLabel.hidden=!(subtitle.length>0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id)initWithSubtitle:(NSString *)subTitle
{
    self=[super initWithNibName:@"spgSMSVerifyViewController" bundle:nil];
    subtitle=subTitle;
    return self;
}

#pragma - mark UI interaction

- (IBAction)getCheckcodeClick:(id)sender {
    [self.view endEditing:YES];
    
    if(timer!=nil)
    {
        [timer invalidate];
    }
    
    __block NSString *errorMsg;
    if (![spgMScooterUtilities isValidMobile:self.PhoneField.text])
    {
        //手机号码不正确
        errorMsg=@"Please enter valid phone number!";
    }
    else
    {
        NSString *zone=kDefaultCountryCode;
        //发送验证码
        [SMS_SDK getVerificationCodeBySMSWithPhone:self.PhoneField.text zone:zone result:^(SMS_SDKError *error)
         {
             if (!error)
             {
                 errorMsg=@"Send verify code success!";
                 [self setGrayButtonState:self.VerifyButton enabled:NO];
                 
                 //1分钟后可重发
                 count=60;
                 timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
                 [timer fire];
             }
             else
             {
                 errorMsg=@"Verify code send failed, Please retry!";
                 [self setGrayButtonState:self.VerifyButton enabled:YES];
             }
             [self notifyUser:errorMsg];
         }];
    }
    
    [self notifyUser:errorMsg];
}

-(void)timerTicked:(NSTimer *)sender{
    if(count==0)
    {
        [timer invalidate];
        [self setGrayButtonState:self.VerifyButton enabled:YES];
    }
    else
    {
        [UIView setAnimationsEnabled:NO];
        NSString *title=[NSString stringWithFormat:@"%ds",count];
        [self.VerifyButton setTitle:title forState:UIControlStateDisabled];
        [UIView setAnimationsEnabled:YES];
    }
    count --;
}

- (IBAction)nextClicked:(id)sender {
    //test
    //self.dismissBlock(self.PhoneField.text);
    //return;
    
    NSString *errorMessage;
    
    //验证，提示格式错误
    if(![spgMScooterUtilities isValidMobile:self.PhoneField.text])
    {
        errorMessage= @"Please enter valid phone number!";
    }
    
    [self notifyUser:errorMessage];
    
    if(!errorMessage)
    {
        //验证验证码
        [SMS_SDK commitVerifyCode:self.VerifycodeField.text result:^(enum SMS_ResponseState state) {
            if (1==state)
            {
                //[self showOptionalView];
                if(self.dismissBlock)
                {
                    self.dismissBlock(self.PhoneField.text);
                }
                [self notifyUser:nil];
            }
            else if(0==state)
            {
                [self notifyUser:@"verify code wrong!"];
            }
        }];
    }
}

- (IBAction)phoneChanged:(id)sender {
    [self updateNextState];
}

- (IBAction)verifycodeChanged:(id)sender {
    [self updateNextState];
}

#pragma - mark custom methods

//设置控件样式
-(void)InitializeUI
{
    spgUITextField *phoneTF=(spgUITextField *)self.PhoneField;
    [phoneTF setLeftImageView:@"mobileIcon.png"];
    [phoneTF setRightButtonView:self.VerifyButton];
    
    [(spgUITextField *)self.VerifycodeField setLeftImageView:@"verificationcodeIcon.png"];
    
    [self setGrayButtonState:self.NextButton enabled:NO];
}

//设置按钮样式
-(void)setGrayButtonState:(UIButton *)button enabled:(BOOL)enabled
{
    button.enabled = enabled;
    button.backgroundColor = enabled? ThemeColor:[UIColor grayColor];
}

//设置下一步按钮状态
-(void)updateNextState
{
    BOOL nextEnabled=self.PhoneField.text.length>0 && self.VerifycodeField.text.length>0;
    [self setGrayButtonState:self.NextButton enabled:nextEnabled];
}

//通知错误
-(void)notifyUser:(NSString *)message
{
    if(self.notifyBlock)
    {
        self.notifyBlock(message);
    }
}
@end
