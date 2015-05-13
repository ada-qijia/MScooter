//
//  spgUITextField.m
//  mScooterNow
//
//  Created by v-qijia on 5/12/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgUITextField.h"

@implementation spgUITextField

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self)
    {
        self.backgroundColor=[UIColor whiteColor];
    }
    return  self;
}

-(CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect leftRect=[super leftViewRectForBounds:bounds];
    leftRect.origin.x+=6;
    return leftRect;
}

-(CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightRect=[super rightViewRectForBounds:bounds];
    rightRect.origin.x-=2;
    return rightRect;
}

#pragma mark - new methods

-(void)setLeftImageView:(NSString *)imageName
{
    UIImage *leftImage=[UIImage imageNamed:imageName];
    if(leftImage)
    {
        self.leftView=[[UIImageView alloc] initWithImage:leftImage];
        self.leftViewMode=UITextFieldViewModeAlways;
    }
}

-(void)setRightButtonView:(UIButton *)rightButton
{
    if(rightButton)
    {
        self.rightView=rightButton;
        self.rightViewMode=UITextFieldViewModeAlways;
    }
}
@end
