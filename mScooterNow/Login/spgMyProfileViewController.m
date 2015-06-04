//
//  spgMyProfileViewController.m
//  mScooterNow
//
//  Created by v-qijia on 5/24/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgMyProfileViewController.h"
#import "spgMScooterCommon.h"
#import "spgChangePasswordViewController.h"
#import "spgProfileItemViewController.h"
#import "spgTabBarViewController.h"

@interface spgMyProfileViewController ()

@end

@implementation spgMyProfileViewController
{
    NSArray *itemIcons;
    NSArray *itemNames;
    NSMutableDictionary *userInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"";
    self.profileButton.layer.borderWidth=2;
    self.profileButton.layer.borderColor=ThemeColor.CGColor;
    
    [self updateUIUserInfo];
    
    itemIcons=[NSArray arrayWithObjects:@"nameIcon.png",@"emailIcon.png",@"passcodeIcon.png", nil];
    itemNames=[NSArray arrayWithObjects:@"Name",@"Email",@"Change Passcode", nil];
}

//clear selection
-(void)viewWillAppear:(BOOL)animated
{
    [self.profileTableView deselectRowAtIndexPath:[self.profileTableView indexPathForSelectedRow] animated:animated];
    
    [super viewWillAppear:animated];
    
    [self.profileTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - public methods

-(void)setNickname:(NSString *)name
{
    if(userInfo!=nil)
    {
        [userInfo setValue:name forKey:@"Nickname"];
    }
    
    //上传
    NSDictionary *user=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[spgMScooterUtilities UserID]],@"ID",
                            name,@"Nickname",
                            nil];
    [self updateUser:user];
}

-(void)setEmail:(NSString *)email
{
    if(userInfo!=nil)
    {
        [userInfo setValue:email forKey:@"Email"];
    }
    
    //上传
    NSDictionary *user=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[spgMScooterUtilities UserID]],@"ID",
                        email,@"Email",
                        nil];
    [self updateUser:user];
}

//设置用户名，头像
-(void)updateUIUserInfo
{
    NSData *jsonData=[spgMScooterUtilities readFromFile:kUserInfoFilename];
    NSDictionary* user =jsonData?[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil]:nil;
    userInfo=[NSMutableDictionary dictionaryWithDictionary:user];
    
    if(userInfo)
    {
        NSString *avatar=[userInfo objectForKey:@"Avatar"];
        if(![avatar isKindOfClass:[NSNull class]])
        {
            NSData *avatarData = [[NSData alloc]
                                  initWithBase64EncodedString:avatar options:0];
            UIImage *img=[UIImage imageWithData:avatarData];
            [self.profileButton setBackgroundImage:img forState:UIControlStateNormal];
        }
    }
    
    [self.profileTableView reloadData];
}

- (IBAction)logout:(id)sender {
    [spgMScooterUtilities setUserID:0];
    bool success = [spgMScooterUtilities saveToFile:kUserInfoFilename data:[NSData data]];
    
    if(success)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSLog(@"clear login info %@",success?@"successfully":@"failed");
}

- (IBAction)profileClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Take Photo", @"Choose From Library",nil];
    [actionSheet showInView:self.view];
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
    [self.profileButton setBackgroundImage:image forState:UIControlStateNormal];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    //上传头像
    NSString *avatar=[self getDataArrayFromImage:image];
    NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[spgMScooterUtilities UserID]],@"UserID",
                            avatar,@"Avatar",
                            nil];
    [self updateUser:userInfo];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image process

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

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==0?2:1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    NSInteger index=indexPath.section *2 +indexPath.row;
    cell.textLabel.text=itemNames[index];
    cell.imageView.image=[UIImage imageNamed:itemIcons[index]];
    
    if(userInfo!=nil)
    {
        if(index==0)
        {
            cell.detailTextLabel.text=[userInfo objectForKey:@"Nickname"];
        }else if(index==1)
        {
            cell.detailTextLabel.text=[userInfo objectForKey:@"Email"];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index=indexPath.section *2 +indexPath.row;
    if(index==0)
    {
        spgProfileItemViewController *itemVC=[[spgProfileItemViewController alloc] init];
        itemVC.title=@"Name";
        itemVC.value=[userInfo objectForKey:@"Nickname"];
        [self.navigationController pushViewController:itemVC animated:YES];
    }
    else if(index==1)
    {
        spgProfileItemViewController *itemVC=[[spgProfileItemViewController alloc] init];
        itemVC.value=[userInfo objectForKey:@"Email"];
        itemVC.title=@"Email";
        [self.navigationController pushViewController:itemVC animated:YES];
    }
    else if(index==2)
    {
        spgChangePasswordViewController *changePasswordVC=[[spgChangePasswordViewController alloc] init];
        [self.navigationController pushViewController:changePasswordVC animated:YES];
    }
}

#pragma mark - upload

-(void)updateUser:(NSDictionary *)user
{
    if(user==nil)
    {
        return;
    }
    
    NSError *error;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:user options:kNilOptions error:&error];
    
    //log
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    
    if(error==nil)
    {
        int userID=[spgMScooterUtilities UserID];
        //url request
        NSString *path=[NSString stringWithFormat:@"%@/UpdateUser?id=%d",kServerUrlBase,userID];
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
                    NSInteger errorCode=[[json objectForKey:@"ErrorCode"] integerValue];
                    NSInteger userID=[[json objectForKey:@"Result"] integerValue];
                    if(!error && errorCode==0 && userID!=0)
                    {
                        NSLog(@"Data= %@", json);
                        //退回上一页
                        /*dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                        });*/
                    }
                    else if (errorCode>0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //self.ErrorLabel.text=[json objectForKey:@"ErrorMessage"];
                        });
                        return;
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //self.ErrorLabel.text=@"change passcode error, please try again.";
                        //self.ErrorLabel.hidden=NO;
                    });
                }
            }}];
        [dataTask resume];
    }
    else
    {
        NSLog(@"Error: json serilization error in MyProfile page");
    }
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
