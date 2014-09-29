//
//  spgVideoCaptureViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>
#include <CoreVideo/CoreVideo.h>

@interface spgVideoCaptureViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

-(void)startVideoCapture;
-(void)stopVideoCapture;


@end
