//
//  spgMyProfileViewController.h
//  mScooterNow
//
//  Created by v-qijia on 5/24/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgMyProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UITableView *profileTableView;

- (IBAction)profileClick:(id)sender;
- (IBAction)logout:(id)sender;

-(void)setNickname:(NSString *)name;
-(void)setEmail:(NSString *)email;
@end
