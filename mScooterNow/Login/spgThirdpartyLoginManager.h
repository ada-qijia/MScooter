//
//  spgThirdpartyLoginViewController.h
//  mScooterNow
//
//  Created by v-qijia on 4/8/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spgMScooterCommon.h"
#import "WeiboUser.h"

@protocol WeiboLoginDelegate <NSObject>

@optional
-(void)weiboLoginReturned:(WBAuthorizeResponse *)response;
-(void)weiboGetUserProfileReturned:(WeiboUser *)user error:(NSError *) error;

@end

@protocol WechatLoginDelegate <NSObject>

@optional
-(void)wechatLoginReturned:(NSString *)openID error:(NSString *)error;

@end

@interface spgThirdpartyLoginManager : NSObject <WeiboSDKDelegate,WBHttpRequestDelegate,WXApiDelegate>

@property (nonatomic, weak) id<WeiboLoginDelegate> weiboDelegate;
@property (nonatomic, weak) id<WechatLoginDelegate> wechatDelegate;

@property (strong, nonatomic) NSString *wbRefreshToken;
@property (strong, nonatomic) NSString *wbAccessToken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

@property (strong, nonatomic) NSString *wbHeaderImgUrl;
@property (strong, nonatomic) NSString *wbNickName;

@property (strong, nonatomic) NSString *wxRefreshToken;
@property (strong, nonatomic) NSString *wxAccessToken;
@property (strong, nonatomic) NSString *wxOpenId;


@property (strong, nonatomic) NSString *wxHeaderImgUrl;
@property (strong, nonatomic) NSString *wxNickName;

+ (spgThirdpartyLoginManager *)sharedInstance;

-(void)weiboLogin;
-(void)weiboLogout;
- (void)weiboShare:(WBMessageObject *)message;

-(void)wechatLogin:(UIViewController *)vc;
-(void)wechatLogout;
- (void)wechatShare;
@end
