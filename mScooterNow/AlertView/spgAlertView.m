//
//  spgAlertView.m
//  mScooterNow
//
//  Created by v-qijia on 12/2/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgAlertView.h"
#import "spgMScooterCommon.h"

#define buttonPadding 10.0f

@interface spgAlertView()

@property (nonatomic,strong)  NSString *correctPasscode;

@end


@implementation spgAlertView

-(id)initWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttonTitles afterDismiss:(spgAlertViewBlock)block
{
    spgAlertView *alertView=[[[NSBundle mainBundle] loadNibNamed:@"spgAlertView" owner:nil options:nil] lastObject];
    
    if([alertView isKindOfClass:[spgAlertView class]])
    {
        self=alertView;
        
        self.title = title;
        self.message = message;
        self.buttons = buttonTitles;
        self.blockAfterDismiss=block;
        
        if(title==nil)
        {
            self.TitleLabel.hidden=YES;
            self.MessageLabel.frame=CGRectMake(12, 12, 240, 90);
        }
        else
        {
          self.TitleLabel.text=self.title;
        }        
        self.MessageLabel.text=self.message;
        
        
        if(self.buttons && self.buttons.count>0)
        {
            float buttonsMargin=6;
            float buttonWidth=(self.ContentView.frame.size.width-2*buttonsMargin-(self.buttons.count-1)*buttonPadding)/self.buttons.count;
            for(int i=0; i<self.buttons.count;i++)
            {
                NSString *buttonTitle = [self.buttons objectAtIndex:i];
                
                UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
                _button.backgroundColor=ThemeColor;
                
                [_button setTitle:buttonTitle forState:UIControlStateNormal];
                _button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
                [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                _button.frame = CGRectMake(buttonsMargin+buttonWidth * i + buttonPadding * i, 115, buttonWidth, 44);
                _button.tag = i;
                
                [_button addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self.ContentView addSubview:_button];
            }
        }
    }
    return self;
}

#pragma - private methods

-(void)onButtonTapped:(id)sender
{
    [self becomeFirstResponder];
    int buttonIndex=(int)((UIButton *)sender).tag;
    
    //wrong passcode
    if(buttonIndex==1 && self.correctPasscode && (![self.TextField1.text isEqualToString:self.correctPasscode]))
    {
        self.TitleLabel.text=@"Wrong, Please Try Again";
        self.TitleLabel.textColor=[UIColor redColor];
        self.TextField1.text=nil;
        [self TextFieldEditingChanged:self.TextField1];
    }
    else
    {
      [self dismissWithAnimation:buttonIndex];
    }
}

-(void)prepareForAnimation
{
    self.BgView.alpha=0;
    CGRect frame=self.ContentView.frame;
    frame.origin.y=-self.ContentView.frame.size.height;
    self.ContentView.frame=frame;
}

-(void)showWithAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        self.BgView.alpha=0.5f;
        self.ContentView.center=CGPointMake(160, 238);
    }];
}

-(void)dismissWithAnimation:(int)buttonIndex
{
    [UIView animateWithDuration:0.2f animations:^{
        self.BgView.alpha=0.0f;
        self.ContentView.center=CGPointMake(160, -self.ContentView.frame.size.height/2);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(self.blockAfterDismiss)
        {
            self.blockAfterDismiss(self.TextField1.text, buttonIndex);
        }
    }];
}

# pragma - passcode mode

-(id)initPasscodeWithTitle:(NSString *)title buttons:(NSArray *)buttonTitles correctPasscode:(NSString *)passcode afterDismiss:(spgAlertViewBlock)block
{
    self= [self initWithTitle:title message:nil buttons:buttonTitles afterDismiss:block];
    
    self.correctPasscode=[passcode copy];
    self.MessageLabel.hidden=YES;
    self.PasscodeView.hidden=NO;
    
    UIButton *okBtn=(UIButton *)[self.ContentView viewWithTag:1];
    okBtn.backgroundColor=[UIColor grayColor];
    okBtn.enabled=NO;
    
    self.TextField1.delegate=self;
    //show keyboard
    [self.TextField1 becomeFirstResponder];
    return self;
}

- (IBAction)PasscodeButtonPressed:(UIButton *)sender {
    /*
    for(UIButton *subview in self.PasscodeView.subviews)
    {
        subview.selected=subview==sender;
    }
    
    [sender setTitle:nil forState:UIControlStateNormal];
    [sender setTitle:nil forState:UIControlStateSelected];
    
    [self.TextField1 becomeFirstResponder];
     */
}

//4 character at most
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return newStr.length<=4;
}

- (IBAction)TextFieldEditingChanged:(id)sender
{
    int length=(int)self.TextField1.text.length;
    for(int i=0;i<4;i++)
    {
        UIButton *btn=(UIButton *)[self.PasscodeView viewWithTag:i+11];
        UIImage *img=i<length?[UIImage imageNamed:@"passcodeDot.png"]:nil;
        [btn setImage:img forState:UIControlStateNormal];
        [btn setImage:img forState:UIControlStateSelected];
        btn.selected=i==length?YES:NO;
    }
    
    UIButton *okBtn=(UIButton *)[self.ContentView viewWithTag:1];
    okBtn.enabled=length==4;
    okBtn.backgroundColor=okBtn.enabled?ThemeColor:[UIColor grayColor];
}
@end
