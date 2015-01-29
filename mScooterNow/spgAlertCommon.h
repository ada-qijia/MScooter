//
//  spgAlertCommon.h
//  mScooterNow
//
//  Created by v-qijia on 1/21/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#ifndef mScooterNow_spgAlertCommon_h
#define mScooterNow_spgAlertCommon_h

typedef void (^spgAlertViewBlock)(NSString *passcode, int buttonIndex);


@protocol spgAlertViewManagerProtocol <NSObject>

-(void)prepareForAnimation;
-(void)showWithAnimation;
-(void)dismissWithAnimation:(int)buttonIndex;
-(void)setAfterDismiss:(spgAlertViewBlock) afterDismiss;
-(spgAlertViewBlock)getAfterDismiss;

@end


#endif
