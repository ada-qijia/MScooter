//
//  spgPinView.h
//  mScooterNow
//
//  Created by v-qijia on 1/21/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spgAlertCommon.h"


@interface spgPinView : UIView <UITextFieldDelegate,spgAlertViewManagerProtocol>

-(id)initWithPin:(NSString *) pin afterDismiss:(spgAlertViewBlock)afterDismiss;

@property (copy, nonatomic) spgAlertViewBlock blockAfterDismiss;

@property (weak, nonatomic) IBOutlet UITextField *TextField1;
- (IBAction)TextFieldEditingChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *TitleImage;
@property (weak, nonatomic) IBOutlet UIView *PinButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *PinButton1;
@property (weak, nonatomic) IBOutlet UIButton *PinButton2;
@property (weak, nonatomic) IBOutlet UIButton *PinButton3;
@property (weak, nonatomic) IBOutlet UIButton *PinButton4;

@end
