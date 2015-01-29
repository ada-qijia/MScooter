//
//  spgPinView.m
//  mScooterNow
//
//  Created by v-qijia on 1/21/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgPinView.h"

@implementation spgPinView
{
    NSString *correctPin;
}

-(id)initWithPin:(NSString *) pin afterDismiss:(spgAlertViewBlock)afterDismiss
{
    spgPinView *pinView=[[[NSBundle mainBundle] loadNibNamed:@"spgPinView" owner:nil options:nil] lastObject];
    
    self=pinView;
    self.blockAfterDismiss=afterDismiss;
    correctPin=[pin copy];
    
    self.TextField1.delegate=self;
    //show keyboard
    //[self.TextField1 becomeFirstResponder];
    
    UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportTap:)];
    [self addGestureRecognizer:singleFingerTap];
    
    return self;
}

-(void)checkPin
{
    //wrong pin
    if(correctPin &&(![self.TextField1.text isEqualToString:correctPin]))
    {
        //self.init
        self.TitleImage.image=[UIImage imageNamed:@"passcodewrong.png"];
        self.TextField1.text=nil;
        [self TextFieldEditingChanged:self.TextField1];
    }
    else
    {
        self.TitleImage.image=[UIImage imageNamed:@"passcode.png"];
        [self dismissWithAnimation:1];
    }
}

#pragma - gesture

//close the page
-(void)reportTap:(UIGestureRecognizer *)recognizer
{
    [self dismissWithAnimation:0];
}

#pragma - delegate methods

-(void)prepareForAnimation
{
    self.TitleImage.alpha=0;
    for (UIView *view in self.PinButtonContainer.subviews)
    {
        view.alpha=0;
    }
}

-(void)showWithAnimation
{
    float deltaDuration=0.15;
    
    [UIView animateWithDuration:deltaDuration delay:0 options: UIViewAnimationOptionCurveLinear animations:^{
        self.TitleImage.alpha=1;
    } completion:^(BOOL finished) {
        //show keyboard
        [self.TextField1 becomeFirstResponder];
    }];
    
    
    [UIView animateWithDuration:deltaDuration animations:^{
        self.TitleImage.alpha=1;
    }];
    
    for (int i=1;i<=self.PinButtonContainer.subviews.count;i++)
    {
        UIView *subView=self.PinButtonContainer.subviews[i-1];
        
        UIViewAnimationOptions option=UIViewAnimationOptionCurveLinear;
        if(i==1)
        {
            option=UIViewAnimationOptionCurveEaseIn;
        }
        else if(i==self.PinButtonContainer.subviews.count)
        {
            option=UIViewAnimationOptionCurveEaseOut;
        }

        [UIView animateWithDuration:deltaDuration delay:deltaDuration*i options: option animations:^{
            subView.alpha=1;
        } completion:nil];
    }
}

-(void)dismissWithAnimation:(int)buttonIndex
{
    float deltaDuration=0.3;
    
    [UIView animateWithDuration:deltaDuration delay:0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha=0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(self.blockAfterDismiss)
        {
            self.blockAfterDismiss(self.TextField1.text, buttonIndex);
        }
    }];
}

-(spgAlertViewBlock)getAfterDismiss
{
    return  self.blockAfterDismiss;
}

-(void)setAfterDismiss:(spgAlertViewBlock) afterDismiss
{
    self.blockAfterDismiss=afterDismiss;
}

#pragma - textfeild delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return newStr.length<=self.PinButtonContainer.subviews.count;
}

#pragma - UI action

- (IBAction)TextFieldEditingChanged:(id)sender
{
    int pinLength=(int)self.PinButtonContainer.subviews.count;
    int length=(int)self.TextField1.text.length;
    for(int i=0;i<pinLength;i++)
    {
        UIButton *btn=(UIButton *)self.PinButtonContainer.subviews[i];
        UIImage *img=i<length?[UIImage imageNamed:@"passcodeDot.png"]:nil;
        [btn setImage:img forState:UIControlStateNormal];
        [btn setImage:img forState:UIControlStateSelected];
        btn.selected=i==length?YES:NO;
    }
    
    //check the passcode
    if(length==pinLength)
    {
        [self checkPin];
    }
}

@end
