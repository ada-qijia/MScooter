//
//  spgAlertView.h
//  mScooterNow
//
//  Created by v-qijia on 12/2/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spgAlertCommon.h"

@interface spgAlertView : UIView <UITextFieldDelegate, spgAlertViewManagerProtocol>

@property (copy, nonatomic) spgAlertViewBlock blockAfterDismiss;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (retain, nonatomic) NSArray *buttons;

-(id)initWithTitle:(NSString*)title
           message:(NSString*)message
           buttons:(NSArray*)buttonTitles
      afterDismiss:(spgAlertViewBlock)block;

-(id)initPasscodeWithTitle:(NSString *)title
           buttons:(NSArray *)buttonTitles
           correctPasscode:(NSString *)passcode
           afterDismiss:(spgAlertViewBlock)block;

//used to show the keyboard
@property (weak, nonatomic) IBOutlet UITextField *TextField1;
- (IBAction)TextFieldEditingChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *BgView;
@property (weak, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *MessageLabel;


@property (weak, nonatomic) IBOutlet UIView *PasscodeView;
@property (weak, nonatomic) IBOutlet UIButton *PasscodeButton1;
@property (weak, nonatomic) IBOutlet UIButton *PasscodeButton2;
@property (weak, nonatomic) IBOutlet UIButton *PasscodeButton3;
@property (weak, nonatomic) IBOutlet UIButton *PasscodeButton4;
- (IBAction)PasscodeButtonPressed:(UIButton *)sender;

@end
