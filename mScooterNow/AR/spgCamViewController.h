//
//  spgCamViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/9/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface spgCamViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *controllerView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

- (IBAction)captureMedia:(UIButton *)sender;

-(void)toggleMovieRecording;
-(void)startVideoCapture;
-(void)stopVideoCapture;
-(void)snapStillImage;
-(void)changeCamera;
-(void)switchMode:(BOOL)toPhoto;

-(void)rotateLayout:(UIInterfaceOrientation)toInterfaceOrientation;
-(void)showInFullScreen:(BOOL)fullScreen;

@end
