//
//  spgDecorationViewCollectionReusableView.m
//  mScooterNow
//
//  Created by v-qijia on 1/22/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgDecorationView.h"

@implementation spgDecorationView

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        UIImageView *imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan.png"]];
        [self addSubview:imgView];
    }
    
    return self;
}

@end
