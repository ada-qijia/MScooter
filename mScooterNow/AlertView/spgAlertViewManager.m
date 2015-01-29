//
//  spgAlertViewManager.m
//  mScooterNow
//
//  Created by v-qijia on 12/2/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgAlertViewManager.h"

@implementation spgAlertViewManager

static spgAlertViewManager* _sharedAlertViewManager=nil;

+(spgAlertViewManager *)sharedAlertViewManager
{
    if(!_sharedAlertViewManager)
    {
        _sharedAlertViewManager=[[spgAlertViewManager alloc] init];
    }
    
    return  _sharedAlertViewManager;
}


-(id)init
{
    self=[super init];
    if(self)
    {
        _alertViewQueue=[[NSMutableArray alloc] init];
        _currentAlertView=nil;
        _isDismissing=nil;
    }
    return self;
}

-(void)dealloc
{
    [_alertViewQueue removeAllObjects];
}

#pragma - private method

-(void)checkoutInStackAlertView
{
    if(_alertViewQueue.count > 0)
    {
        UIView<spgAlertViewManagerProtocol> *entity = [_alertViewQueue lastObject];
        [self showAlertViewWithAnimation:entity];
    }
}

-(void)showAlertViewWithAnimation:(UIView<spgAlertViewManagerProtocol> *)entity
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    //NSArray *windows = [UIApplication sharedApplication].windows;
    //if(windows.count > 0) keyWindow = [windows lastObject];
    
    [entity prepareForAnimation];
    [keyWindow addSubview:entity];
    _currentAlertView=entity;
    [entity showWithAnimation];
}

-(void)dismissAlertViewWithAnimation:(UIView<spgAlertViewManagerProtocol> *)entity button:(int)buttonIndex
{
    spgAlertViewBlock afterDismiss=^(NSString* passcode, int index){
        [_alertViewQueue removeLastObject];
        _currentAlertView=nil;
        _isDismissing=NO;
        [self checkoutInStackAlertView];
        
        if(self.blockAfterDismiss)
        {
            self.blockAfterDismiss(passcode, buttonIndex);
        }
    };
    [entity setAfterDismiss:afterDismiss];
    [entity dismissWithAnimation:buttonIndex];
}

#pragma - public methods

-(void)show:(UIView<spgAlertViewManagerProtocol> *)alertView
{
    if(alertView)
    {
        if(_isDismissing==YES && _alertViewQueue.count>0)
        {
            [_alertViewQueue insertObject:alertView atIndex:_alertViewQueue.count-1];
        }
        else
        {
            [_alertViewQueue addObject:alertView];
            [_currentAlertView removeFromSuperview];
            
            [self showAlertViewWithAnimation:alertView];
        }
    }
}

-(void)dismiss:(UIView<spgAlertViewManagerProtocol> *)alertView
{
    [self dismiss:alertView button:0];
}

-(void)dismiss:(UIView<spgAlertViewManagerProtocol> *)alertView button:(int)buttonIndex
{
    if(_alertViewQueue.count<=0)
        return;
    
    if(alertView)
    {
        _isDismissing=YES;
        if([alertView isEqual:[_alertViewQueue lastObject]])
        {
            [self dismissAlertViewWithAnimation:alertView button:buttonIndex];
        }
        else
        {
            [_alertViewQueue removeObject:alertView];
            spgAlertViewBlock afterDismiss=[alertView getAfterDismiss];
            afterDismiss(nil,buttonIndex);
        }
    }
}

@end
