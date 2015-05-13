//
//  WechatTimelineActivity.m
//  mScooterNow
//
//  Created by v-qijia on 4/22/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "WechatTimelineActivity.h"

@implementation WechatTimelineActivity

-(id)init
{
    self=[super initWithScene:WXSceneTimeline];
    return self;
}

-(NSString *)activityTitle
{
    return @"微信朋友圈";
}

-(UIImage *)activityImage
{
    return [UIImage imageNamed:@"wechat-timeline.png"];
}

@end
