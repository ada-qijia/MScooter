//
//  spgChangePasswordViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/20/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgChangePasswordViewController.h"
#import "spgUITextField.h"
#import "spgMScooterCommon.h"

@interface spgChangePasswordViewController ()

@end

@implementation spgChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeUI];
    
    //dismiss keyboard when tap outside of textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - UI interaction

//upload
- (IBAction)okClicked:(UIButton *)sender {
    if(![self.NewPasscodeTextField.text isEqualToString:self.RenewPasscodeTextField.text])
    {
        self.ErrorLabel.text=@"please enter same new passcode.";
        self.ErrorLabel.hidden=NO;
        return;
    }
    else
    {
        self.ErrorLabel.hidden=YES;
    }
    
    int userID=[spgMScooterUtilities UserID];
    if(userID==0) return;
    NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:userID],@"ID",
                            self.OldPasscodeTextField.text,@"OldPassword",
                            self.NewPasscodeTextField.text,@"NewPassword",
                            nil];
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
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self setActivityIndicatorVisibility:YES];
        NSURLSession *sharedSession=[NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask=[sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self setActivityIndicatorVisibility:NO];
            NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
            if(httpResponse.statusCode==200)
            {
                if(error==nil)
                {
                    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSLog(@"Data= %@", json);
                    NSInteger errorCode=[[json objectForKey:@"ErrorCode"] integerValue];
                    if(errorCode==0)
                    {
                        //退回上一页
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.ErrorLabel.text=[json objectForKey:@"ErrorMessage"];
                            self.ErrorLabel.hidden=NO;
                        });
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.ErrorLabel.text=@"change passcode error, please try again.";
                        self.ErrorLabel.hidden=NO;
                    });
                }
            }}];
        [dataTask resume];
    }
}

- (IBAction)passcodeChanged:(id)sender {
    BOOL btnEnabled=self.OldPasscodeTextField.text.length>0 && self.NewPasscodeTextField.text.length>0 && self.RenewPasscodeTextField.text.length>0;
    self.OKButton.enabled = btnEnabled;
    self.OKButton.backgroundColor = btnEnabled? ThemeColor:[UIColor grayColor];
}

#pragma - Gesture callback

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

//设置控件样式
-(void)initializeUI
{
    [(spgUITextField *)self.OldPasscodeTextField setLeftImageView:@"passcodeIcon.png"];
    [(spgUITextField *)self.NewPasscodeTextField setLeftImageView:@"passcodeIcon.png"];
    [(spgUITextField *)self.RenewPasscodeTextField setLeftImageView:@"passcodeIcon.png"];
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
