//
//  spgAlertViewManager.h
//  mScooterNow
//
//  Created by v-qijia on 12/2/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "spgAlertView.h"

@interface spgAlertViewManager : NSObject
{
    NSMutableArray *_alertViewQueue;
    id _currentAlertView;
    
    BOOL _isDismissing;
}

@property (copy, nonatomic) spgAlertViewBlock blockAfterDismiss;

+(spgAlertViewManager *)sharedAlertViewManager;

-(void)show:(spgAlertView *)alertView;
-(void)dismiss:(spgAlertView *)alertView;
-(void)dismiss:(spgAlertView *)alertView button:(int)buttonIndex;

@end
