//
//  spgAssetViewController.h
//  mScooterNow
//
//  Created by v-qijia on 1/13/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Photos/Photos.h>

@interface spgAssetViewController : UIViewController<UIImagePickerControllerDelegate>

@property (weak,nonatomic) NSMutableDictionary* assets;
@property NSInteger currentIndex;
@property(strong, nonatomic) MPMoviePlayerController* movieController;

@property (weak, nonatomic) IBOutlet UIView *ItemView;
@property (weak, nonatomic) IBOutlet UIImageView *LargeImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)DeleteClicked:(UIButton *)sender;
- (IBAction)CloseClicked:(UIButton *)sender;

@end
