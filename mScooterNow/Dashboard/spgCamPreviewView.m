//
//  spgCamPreviewView.m
//  mScooterNow
//
//  Created by v-qijia on 10/9/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation spgCamPreviewView

+(Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

-(AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

-(void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}

@end
