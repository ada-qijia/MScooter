//
//  spgAlertViewManager.h
//  mScooterNow
//
//  Created by v-qijia on 12/2/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "spgAlertView.h"
#import "spgPinView.h"
#import "spgAlertCommon.h"

@interface spgAlertViewManager : NSObject
{
    NSMutableArray *_alertViewQueue;
    id _currentAlertView;
    
    BOOL _isDismissing;
}

@property (copy, nonatomic) spgAlertViewBlock blockAfterDismiss;

+(spgAlertViewManager *)sharedAlertViewManager;

-(void)show:(UIView<spgAlertViewManagerProtocol> *)alertView;
-(void)dismiss:(UIView<spgAlertViewManagerProtocol> *)alertView;
-(void)dismiss:(UIView<spgAlertViewManagerProtocol> *)alertView button:(int)buttonIndex;

@end
