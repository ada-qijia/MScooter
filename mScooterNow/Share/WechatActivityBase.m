//
//  WechatActivityBase.m
//  mScooterNow
//
//  Created by v-qijia on 4/22/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "WechatActivityBase.h"

@implementation WechatActivityBase

#pragma - mark custom interface

- (id)initWithScene:(enum WXScene)scene
{
    self=[super init];
    if(self)
    {
        wxscene=scene;
    }
    return  self;
}

#pragma - mark UIActivity methods

+(UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

-(NSString *)activityType
{
    return  NSStringFromClass([self class]);
}

-(NSString *)activityTitle
{
    return @"微信";
}

-(UIImage *)activityImage
{
    return [UIImage imageNamed:@"wechat-session.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        return YES;
    }
    return NO;
}

-(void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            title = activityItem;
        }
    }
}

//发送多媒体消息
-(void)performActivity
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = wxscene;
    
    req.message = WXMediaMessage.message;
    if(req.scene==WXSceneSession)
    {
        req.message.title = @"wonderful neezza moments";
        req.message.description = title;
    }else{
        req.message.title=title;
    }
    
    if(image)
    {
        [req.message setThumbImage:[self getThumbImage:image]];
    }
    
    if (url) {
        WXWebpageObject *webObject = WXWebpageObject.object;
        webObject.webpageUrl = [url absoluteString];
        req.message.mediaObject = webObject;
    } else if (image) {
        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(image, 1);
        req.message.mediaObject = imageObject;
    }
    
    [WXApi sendReq:req];
    [self activityDidFinish:YES];
}

- (UIImage *)getThumbImage:(UIImage *)sourceImage
{
    if (sourceImage) {
        CGFloat width = 100.0f;
        CGFloat height = sourceImage.size.height * 100.0f / sourceImage.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [sourceImage drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage;
    }
    return nil;
}

@end
