//
//  spgSMSVerifyViewController.h
//  mScooterNow
//
//  Created by v-qijia on 5/14/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgSMSVerifyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *PhoneField;
@property (weak, nonatomic) IBOutlet UIButton *VerifyButton;
@property (weak, nonatomic) IBOutlet UITextField *VerifycodeField;
@property (weak, nonatomic) IBOutlet UIButton *NextButton;

- (IBAction)getCheckcodeClick:(id)sender;
- (IBAction)nextClicked:(id)sender;
- (IBAction)phoneChanged:(id)sender;
- (IBAction)verifycodeChanged:(id)sender;

@property (nonatomic, copy) void (^notifyBlock)(NSString *message);
@property (nonatomic, copy) void (^dismissBlock)(NSString *phoneNumber);

-(id)initWithSubtitle:(NSString *)subTitle;
@end
