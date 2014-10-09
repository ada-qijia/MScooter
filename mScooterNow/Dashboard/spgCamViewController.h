//
//  spgCamViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/9/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgCamViewController : UIViewController

-(void)toggleMovieRecording;
-(void)startVideoCapture;
-(void)stopVideoCapture;
-(void)snapStillImage;
-(void)changeCamera;

@end
