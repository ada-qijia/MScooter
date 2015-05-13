//
//  WechatSessionActivity.m
//  mScooterNow
//
//  Created by v-qijia on 4/22/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "WechatSessionActivity.h"

@implementation WechatSessionActivity

-(id)init
{
    self=[super initWithScene:WXSceneSession];
    return self;
}

-(NSString *)activityTitle
{
    return @"微信好友";
}

-(UIImage *)activityImage
{
    return [UIImage imageNamed:@"wechat-session.png"];
}

@end
