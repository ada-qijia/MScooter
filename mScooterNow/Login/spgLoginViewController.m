//
//  spgLoginViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/21/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgLoginViewController.h"
#import "spgTabBarViewController.h"
#import "spgMScooterCommon.h"
#import "WXApi.h"
#import "spgAppDelegate.h"
#import "spgThirdpartyLoginManager.h"
#import "spgUserRegisterViewController.h"

#import "spgRetrievePasswordViewController.h"

@interface spgLoginViewController ()

@end

@implementation spgLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGradient.jpg"]]];
    
    [spgThirdpartyLoginManager sharedInstance].weiboDelegate=self;
    [spgThirdpartyLoginManager sharedInstance].wechatDelegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - textFeild delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    //[textField resignFirstResponder];
    return YES;
}

#pragma mark - UI interaction

- (IBAction)loginClicked:(UIButton *)sender {
    NSString *mobile=self.phoneTextField.text;
    NSString *passcode=self.passcodeTextField.text;
    if(![spgMScooterUtilities isValidMobile:mobile])
    {
        self.errorLabel.text=@"Please enter correct phone No.";
        self.errorLabel.hidden=NO;
    }
    else if(!passcode.length)
    {
        self.errorLabel.text=@"Please enter passcode";
        self.errorLabel.hidden=NO;
    }
    else
    {
        self.errorLabel.text=nil;
        self.errorLabel.hidden=YES;
        
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:mobile,@"Phone",passcode,@"Password",nil];
        NSError *error;
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:userInfo options:kNilOptions error:&error];
        if(error==nil)
        {
            //url request
            NSString *path=[NSString stringWithFormat:@"%@/Login",kServerUrlBase];
            NSURL *url=[NSURL URLWithString:path];
            NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:jsonData];
            [urlRequest addValue:@"application/json"forHTTPHeaderField:@"Content-Type"];
            
            NSURLSession *sharedSession=[NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask=[sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(error==nil)
                {
                    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSInteger userID=[[json objectForKey:@"ID"] integerValue];
                    if(!error && userID>0)
                    {
                        [spgMScooterUtilities setUserID:(int)userID];
                        
                        //save to file
                        BOOL success = [spgMScooterUtilities saveToFile:kUserInfoFilename data:data];
                        NSLog(success?@"yes":@"no");
                    }
                    NSString *text=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"Data= %@", text);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.parentViewController viewWillAppear:NO];
                    [self.view removeFromSuperview];
                    [self removeFromParentViewController];
                });
            }];
            
            [dataTask resume];
        }
        else
        {
            NSLog(@"Parse param to json error: %@",error.description);
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }
}

- (IBAction)backClicked:(UIButton *)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

//忘记密码, 导向找回密码页
- (IBAction)forgetPasscodeClick:(id)sender {
    spgRetrievePasswordViewController *retrieveVC=[[spgRetrievePasswordViewController alloc] initWithNibName:@"spgRetrievePasswordViewController" bundle:nil];
    [self presentViewController:retrieveVC animated:YES completion:nil];
}

- (IBAction)weiboLogin:(UIButton *)sender {
    [[spgThirdpartyLoginManager sharedInstance] weiboLogin];
}

- (IBAction)weixinLogin:(UIButton *)sender {
    [[spgThirdpartyLoginManager sharedInstance] wechatLogin:self];
    /*
     SendAuthReq* req = [[SendAuthReq alloc] init];
     req.scope = @"snsapi_userinfo";//"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
     req.state = @"xxx";
     req.openID = @"0c806938e2413ce73eef92cc3";
     
     spgAppDelegate *appDelegate=(spgAppDelegate *)[[UIApplication sharedApplication] delegate];
     [WXApi sendAuthReq:req viewController:self delegate:appDelegate];*/
}

- (IBAction)registerClick:(UIButton *)sender {
    spgUserRegisterViewController *registerVC=[[spgUserRegisterViewController alloc] init];
    registerVC.LoginVC=self;
    [self presentViewController:registerVC animated:YES completion:nil];
}

#pragma - mark WeiboLoginDelegate
-(void)weiboLoginReturned:(WBAuthorizeResponse *)response
{
    if(response.statusCode!=0)
    {
        NSLog(@"weiboLogin error: %@.", response.description);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.errorLabel.text=@"weibo login error!";
            self.errorLabel.hidden=NO;
        });
    }
}

-(void)weiboGetUserProfileReturned:(WeiboUser *)user error:(NSError*) error
{
    if (error || user==nil)
    {
        NSLog(@"weiboGetUserProfile error: %@.", error.description);
        //退回设置页
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentViewController viewWillAppear:NO];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        });
    }
    else
    {
        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:user.profileImageUrl]];
        [self registerThirdPartyUser:2 openID:user.userID nickname:user.screenName avatar:data];
    }
}

-(void)registerThirdPartyUser:(int) partyType openID:(NSString *)openID nickname:(NSString *)nickname avatar:(NSData *)avatar
{
    NSString *profile64=[avatar base64EncodedStringWithOptions:0];
    
    NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"ScooterUsage",
                            nickname,@"Nickname",
                            @"",@"Password",
                            @"",@"PhoneNumber",
                            profile64,@"Avatar",
                            [NSNumber numberWithInt:partyType],@"RegisterType",
                            openID,@"OpenID",
                            nil];
    NSError *error;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:userInfo options:kNilOptions error:&error];
    //NSString *sendData=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(error==nil)
    {
        //url request
        NSString *path=[NSString stringWithFormat:@"%@/Register",kServerUrlBase];
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
                    [spgMScooterUtilities setUserID:(int)[text integerValue]];
                    
                    //save to file
                    [spgMScooterUtilities saveToFile:kUserInfoFilename data:jsonData];
                }
            }
            //退回设置页
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.parentViewController viewWillAppear:NO];
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            });
        }];
        [dataTask resume];
    }
}

#pragma - mark wechatLoginDelegate

-(void)wechatLoginReturned:(NSString *)openID error:(NSString *)error
{
    if(error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.errorLabel.text=@"wechat login error!";
            self.errorLabel.hidden=NO;
        });
    }else if(openID)
    {
        [self registerThirdPartyUser:3 openID:openID nickname:nil avatar:nil];
    }
}
@end
