//
//  spgCamPreviewView.h
//  mScooterNow
//
//  Created by v-qijia on 10/9/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface spgCamPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
