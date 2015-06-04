//
//  spgThirdpartyLoginViewController.m
//  mScooterNow
//
//  Created by v-qijia on 4/8/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgThirdpartyLoginManager.h"

@interface spgThirdpartyLoginManager ()

@end

@implementation spgThirdpartyLoginManager

#pragma mark - singleton

+(spgThirdpartyLoginManager *)sharedInstance
{
    static spgThirdpartyLoginManager *sharedManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Weibo

-(void)weiboLogin
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    //http://open.weibo.com/wiki/Scope
    request.scope = @"all";
    request.userInfo = nil;
    [WeiboSDK sendRequest:request];
}

-(void)weiboLogout
{
    [WeiboSDK logOutWithToken:self.wbAccessToken delegate:self withTag:@"user1"];
}

- (void)weiboShare:(WBMessageObject *)message
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbAccessToken];
    request.userInfo = @{@"ShareMessageFrom": @"Nezzaa"};
    [WeiboSDK sendRequest:request];
}

- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    //0:text; 1:image; 2:webpage
    int type=0;
    if (type==0)
    {
        message.text = NSLocalizedString(@"测试通过WeiboSDK发送文字到微博!", nil);
    }
    
    else if (type==1)
    {
        WBImageObject *image = [WBImageObject object];
        image.imageData =[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]];
        //[UIImagePNGRepresentation([UIImage imageNamed:@""])];
        message.imageObject = image;
    }
    
    else if (type==2)
    {
        WBWebpageObject *webpage = [WBWebpageObject object];
        webpage.objectID = @"identifier1";
        webpage.title = NSLocalizedString(@"分享网页标题", nil);
        webpage.description = [NSString stringWithFormat:NSLocalizedString(@"分享网页内容简介-%.0f", nil), [[NSDate date] timeIntervalSince1970]];
        webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
        webpage.webpageUrl = @"http://sina.cn?a=1";
        message.mediaObject = webpage;
    }
    
    return message;
}

-(void)weiboGetUserProfile
{
    [WBHttpRequest requestForUserProfile:self.wbCurrentUserID withAccessToken:self.wbAccessToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        
        WeiboUser *wbUser= (WeiboUser *)result;
        if(!error)
        {
            self.wbNickName=wbUser.screenName;
            self.wbHeaderImgUrl=wbUser.profileImageUrl;
        }
        
        if([self.weiboDelegate respondsToSelector:@selector(weiboGetUserProfileReturned:error:)])
        {
            [self.weiboDelegate weiboGetUserProfileReturned:wbUser error:error];
        }
        
        /*if (error)
         {
         NSLog(@"weiboGetUserProfile error: %@.", error.description);
         }
         else
         {
         WeiboUser *wbUser= (WeiboUser *)result;
         [spgThirdpartyLoginManager sharedInstance].wbNickName=wbUser.screenName;
         [spgThirdpartyLoginManager sharedInstance].wbHeaderImgUrl=wbUser.profileImageUrl;
         }*/
    }];
}

//返回错误21327时，token过期
- (void)weiboRenewAccessToken
{
    [WBHttpRequest requestForRenewAccessTokenWithRefreshToken:self.wbAccessToken queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        if (error)
        {
            //请求错误
        }
        else
        {
            //更新Token
        }
    }];
}

#pragma mark - weibo delegate

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        WBAuthorizeResponse *authResponse= (WBAuthorizeResponse *)response;
        
        if(response.statusCode==0)
        {
            self.wbAccessToken = [authResponse accessToken];
            self.wbRefreshToken= [authResponse refreshToken];
            self.wbCurrentUserID = [authResponse userID];
            //获取用户信息
            [self weiboGetUserProfile];
        }
        
        if([self.weiboDelegate respondsToSelector:@selector(weiboLoginReturned:)])
        {
            [self.weiboDelegate weiboLoginReturned:authResponse];
        }
        
        /*
         if(response.statusCode!=0)
         {
         NSString *title = NSLocalizedString(@"认证结果", nil);
         NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,nil, nil,  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
         message:message
         delegate:nil
         cancelButtonTitle:NSLocalizedString(@"确定", nil)
         otherButtonTitles:nil];
         [alert show];
         }
         else
         { }*/
    }
}

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

#pragma mark - Wechat
//http://www.cnblogs.com/EverNight/p/4074304.html

-(void)wechatLogin:(UIViewController *)vc
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";//"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
    req.state =@"Neezza";
    //req.openID = @"0c806938e2413ce73eef92cc3";
    [WXApi sendAuthReq:req viewController:vc delegate:self];
}

//can not be done.
-(void)wechatLogout
{
    
}

//text, image, link, video
- (void)wechatShare
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = @"人文的东西并不是体现在你看得到的方面，它更多的体现在你看不到的那些方面，它会影响每一个功能，这才是最本质的。但是，对这点可能很多人没有思考过，以为人文的东西就是我们搞一个很小清新的图片什么的。”综合来看，人文的东西其实是贯穿整个产品的脉络，或者说是它的灵魂所在。";
    req.bText = YES;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

-(void)wechatGetTokenWithCode:(NSString *)code
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWechatAppId,kWechatAppSecret, code];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([dict objectForKey:@"errcode"])
                {
                    //获取token错误
                    [self handleError:[[dict objectForKey:@"errcode"] stringValue] withTitle:@"获取凭证错误"];
                }else{
                    //https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&lang=zh_CN
                    //存储AccessToken OpenId RefreshToken以便下次直接登陆
                    //AccessToken有效期两小时，RefreshToken有效期三十天
                    self.wxAccessToken=[dict objectForKey:@"access_token"];
                    self.wxRefreshToken=[dict objectForKey:@"refresh_token"];
                    self.wxOpenId=[dict objectForKey:@"openid"];
                    
                    [self wechatGetUserProfileWithToken:[dict objectForKey:@"access_token"] andOpenId:[dict objectForKey:@"openid"]];
                    
                    if([self.wechatDelegate respondsToSelector:@selector(wechatLoginReturned:error:)])
                    {
                        [self.wechatDelegate wechatLoginReturned:self.wxOpenId error:nil];
                    }
                }
            }
        });
    });
}

-(void)wechatGetUserProfileWithToken:(NSString *)accessToken andOpenId:(NSString *)openId
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                if ([dict objectForKey:@"errcode"])
                {
                    //AccessToken失效
                    [self wechatRefreshToken:self.wxRefreshToken];
                }else{
                    //获取需要的数据
                    self.wxHeaderImgUrl= [dict objectForKey:@"headimgurl"];
                    self.wxNickName= [dict objectForKey:@"nickname"];
                }
            }
        });
    });
}

- (void)wechatRefreshToken:(NSString *)refreshToken
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",kWechatAppId,refreshToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([dict objectForKey:@"errcode"])
                {
                    [self handleError:@"授权过期" withTitle:@"授权错误"];
                }else{
                    //重新使用AccessToken获取信息
                    self.wxAccessToken=[dict objectForKey:@"access_token"];
                    self.wxRefreshToken=[dict objectForKey:@"refresh_token"];
                    self.wxOpenId=[dict objectForKey:@"openid"];
                }
            }
        });
    });
}

#pragma mark - Wechat delegate

-(void)onReq:(BaseReq *)req
{
    
}

-(void)onResp:(BaseResp *)resp
{
    if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        /*
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        if(temp.errCode==-2)
        {
            [self handleError:@"用户取消" withTitle:strTitle];
        }
        else if(temp.errCode==-4)
        {
            [self handleError:@"用户拒绝" withTitle:strTitle];
        }
        else if(temp.errCode!=0)
        {
            //其他认证错误
            NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", temp.code, temp.state, temp.errCode];
            [self handleError:strMsg withTitle:strTitle];
        }
        else
        {
            //获取token
            [self wechatGetTokenWithCode:temp.code];
        }*/
        
        NSLog(@"wechat log::code:%@,state:%@,errcode:%d", temp.code, temp.state, temp.errCode);
        
        if(temp.errCode==0)
        {
            //获取token
           [self wechatGetTokenWithCode:temp.code];
        }
        else if(temp.errCode!=0 && [self.wechatDelegate respondsToSelector:@selector(wechatLoginReturned:error:)])
        {
            [self.wechatDelegate wechatLoginReturned:nil error:temp.errStr];
        }
    }
}

#pragma mark - common hanlder

-(void)handleError:(NSString *)error withTitle:(NSString *) title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
