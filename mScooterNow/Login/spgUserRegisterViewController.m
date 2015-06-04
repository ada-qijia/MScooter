//
//  spgUserRegisterViewController.m
//  mScooterNow
//
//  Created by v-qijia on 4/9/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgUserRegisterViewController.h"
#import "spgMScooterCommon.h"

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>

#import "spgUITextField.h"
#import "spgSMSVerifyViewController.h"

#import "spgTabBarViewController.h"

@interface spgUserRegisterViewController ()
{
    CountryAndAreaCode* _data2;
    NSMutableArray* _areaArray;
    NSString* _currentAreaCode;
    NSString* _defaultCode;
    NSString* _defaultCountryName;
    NSURLSession *ephemeralSession;
    
    NSString* phone;
    spgSMSVerifyViewController *verifyVC;
}

@end

@implementation spgUserRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"";
    self.ChooseCountryButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    
    [self AddVerifyView];
    //设置UI
    [self setTextFieldsUI];
    
    /*
     //设置本地区号
     [self setTheLocalAreaCode];
     //获取支持的地区列表
     [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array)
     {
     if (1==state)
     {
     NSLog(@"sucessfully get the area code");
     //区号数据
     _areaArray=[NSMutableArray arrayWithArray:array];
     }
     else if (0==state)
     {
     NSLog(@"failed to get the area code");
     }
     
     }];*/
    
    //设置国家为中国
    _defaultCode=@"86";
    _defaultCountryName=@"China";
    _currentAreaCode=_defaultCode;
    
    //设置url session
    NSURLSessionConfiguration *ephemeralConfig=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    ephemeralSession=[NSURLSession sessionWithConfiguration:ephemeralConfig];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//close the keyborad
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - CountryCodeViewControllerDelegate
-(void)setCountryCodeData:(CountryAndAreaCode *)data
{
    _data2=data;
    _currentAreaCode=_data2.areaCode;
    [self.ChooseCountryButton setTitle:data.countryName forState:UIControlStateNormal];
}

#pragma mark - set local country/area
-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt=[locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode=[dictCodes objectForKey:tt];
    NSString* defaultCountryName=[locale displayNameForKey:NSLocaleCountryCode value:tt];
    _defaultCode=defaultCode;
    _defaultCountryName=defaultCountryName;
    
    _currentAreaCode=defaultCode;
    [self.ChooseCountryButton setTitle:defaultCountryName forState:UIControlStateNormal];
}

#pragma mark - navigate

- (IBAction)ChooseCountryClick:(id)sender {
    CountryCodeViewController *countryVC=[[CountryCodeViewController alloc] init];
    countryVC.delegate=self;
    [countryVC setAreaArray:_areaArray];
    [self presentViewController:countryVC animated:YES completion:nil];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - register step 1

-(void)AddVerifyView
{
    __weak typeof(self) weakSelf = self;
    verifyVC=[[spgSMSVerifyViewController alloc] initWithSubtitle:@"Use Your Phone To Register"];
    verifyVC.dismissBlock=^(NSString *phoneNumber){
        phone = phoneNumber;
        [weakSelf showOptionalView];
    };
    verifyVC.notifyBlock=^(NSString *message){
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.errorLabel.text=message;
            weakSelf.errorLabel.hidden=!(message.length>0);
        });
    };
    
    verifyVC.view.frame=CGRectMake(0, 65, 320, 270);
    [self.view addSubview:verifyVC.view];
}

#pragma mark - register step 2

- (IBAction)avatarClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Take Photo", @"Choose From Library",nil];
    [actionSheet showInView:self.view];
}

- (IBAction)HidePasscode:(id)sender {
    self.passcodeField.secureTextEntry=true;
}

- (IBAction)showPasscode:(id)sender {
    self.passcodeField.secureTextEntry=false;
}

- (IBAction)submitClick:(id)sender {
    [self.view endEditing:YES];
    
    //格式检验
    __block NSString *errorMessage;
    /*
     if(![self isValidEmail:self.emailField.text])
     {
     errorMessage=@"Please enter a valid email address!";
     }
     else if(!self.nicknameField.text.length)
     {
     errorMessage=@"Please enter a nickname!";
     }
     else */
    
    /*
     else if(![self.passcodeField.text isEqualToString:self.confirmPasscodeField.text])
     {
     errorMessage= @"Please enter the same passcode!";
     }*/
    if(!self.nicknameField.text.length)
    {
        errorMessage= @"Please enter a nickname!";
    }
    else if(self.passcodeField.text.length<5)
    {
        errorMessage= @"Password must be longer than 4!";
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
    
    [self register];
}

//提交服务器
-(void)register
{
    [self.view endEditing:YES];
    
    NSString *avatar=[self getDataArrayFromImage:self.avatarButton.currentImage];
    NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"ScooterUsage",
                            self.emailField.text,@"Email",
                            self.nicknameField.text,@"Nickname",
                            self.passcodeField.text,@"Password",
                            //self.ChooseCountryButton.titleLabel.text,@"Country",
                            phone,@"PhoneNumber",
                            avatar,@"Avatar",
                            [NSNumber numberWithInt:1],@"RegisterType",
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
        
        [self setActivityIndicatorVisibility:YES];
        NSURLSessionDataTask *dataTask=[ephemeralSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setActivityIndicatorVisibility:NO];
            });
            NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
            NSString *text=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Data= %@", text);
            if(httpResponse.statusCode==200 && error==nil)
            {
                if([text integerValue]>0)
                {
                    //save to file
                    [spgMScooterUtilities saveToFile:kUserInfoFilename data:jsonData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:NO];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                    return;
                }
            }
            else if(httpResponse.statusCode==400)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.errorLabel.text=@"param error!";
                    self.errorLabel.hidden=NO;});
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.errorLabel.text=@"register failed!";
                self.errorLabel.hidden=NO;});
        }];
        [dataTask resume];
    }
}

//http://iosdevelopertips.com/core-services/encode-decode-using-base64.html
-(NSString *)getDataArrayFromImage:(UIImage *)image
{
    UIImage *thumb=[self getThumbImage:image];
    NSData *data=[NSData dataWithData:UIImageJPEGRepresentation(thumb, 1.0)];
    NSString *base64Encoded=[data base64EncodedStringWithOptions:0];
    return base64Encoded;
}

- (UIImage *)getThumbImage:(UIImage *)sourceImage
{
    if (sourceImage) {
        CGFloat width = 80.0f;
        CGFloat height = sourceImage.size.height * 80.0f / sourceImage.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [sourceImage drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage;
    }
    return nil;
}


#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)//take photo
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if(buttonIndex==1)//choose from library
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else//cancel
    {
        return;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType{
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle=UIModalPresentationCurrentContext;
        imagePickerController.sourceType=sourceType;
        imagePickerController.allowsEditing=YES;
        imagePickerController.delegate=self;
        spgTabBarViewController *tabVC=(spgTabBarViewController *) self.navigationController.parentViewController;
        [tabVC presentViewController:imagePickerController animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Invalid Operation" message:@"SourceType is not supported!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil ];
        [alert show];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    [self.avatarButton setImage:image forState:UIControlStateNormal];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - custom methods

- (BOOL)isValidPassword {
    return (self.passcodeField.text.length >= 5);
}

-(void) showOptionalView
{
    CATransition *transition=[CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    transition.subtype = kCATransitionFromRight;
    
    [verifyVC.view.layer addAnimation:transition forKey:nil];
    [self.optionalInfoView.layer addAnimation:transition forKey:nil];
    
    verifyVC.view.hidden=YES;
    self.optionalInfoView.hidden=NO;
}

//设置控件样式
-(void)setTextFieldsUI
{
    [(spgUITextField *)self.nicknameField setLeftImageView:@"nameIcon.png"];
    
    spgUITextField *passcodeTF=(spgUITextField *)self.passcodeField;
    [passcodeTF setLeftImageView:@"passcodeIcon.png"];
    [passcodeTF setRightButtonView:self.viewPasscodeButton];
    
    [(spgUITextField *)self.emailField setLeftImageView:@"emailIcon.png"];
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
