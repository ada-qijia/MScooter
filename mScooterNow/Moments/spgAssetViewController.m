//
//  spgAssetViewController.m
//  mScooterNow
//
//  Created by v-qijia on 1/13/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgAssetViewController.h"

@interface spgAssetViewController ()

@end

@implementation spgAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    UISwipeGestureRecognizer *horizontalLeftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalLeftSwipe:)];
    horizontalLeftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:horizontalLeftSwipe];
    
    UISwipeGestureRecognizer *horizontalRightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalRightSwipe:)];
    horizontalRightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontalRightSwipe];
    
    UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setCurrentItemView];
}

#pragma -gesture
//next
-(void)reportHorizontalLeftSwipe:(UIGestureRecognizer *)recognizer
{
    CATransition *transition=[self getPushTransition];
    transition.subtype = kCATransitionFromRight;
    [self.ItemView.layer addAnimation:transition forKey:nil];
    
    self.currentIndex=(self.currentIndex+1)%self.assets.count;
    [self setCurrentItemView];
}

//pre
-(void)reportHorizontalRightSwipe:(UIGestureRecognizer *)recognizer
{
    CATransition *transition=[self getPushTransition];
    transition.subtype = kCATransitionFromLeft;
    [self.ItemView.layer addAnimation:transition forKey:nil];
    
    self.currentIndex=(self.currentIndex+self.assets.count-1)%self.assets.count;
    [self setCurrentItemView];
}

//close the page
-(void)reportTap:(UIGestureRecognizer *)recognizer
{
      [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma -video play

- (IBAction)playVideo:(id)sender
{
     PHAsset *asset=[self.assets objectAtIndex:self.currentIndex];
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if ([playerItem.asset isKindOfClass:AVURLAsset.class])
        {
            NSURL *theURL = [(AVURLAsset *)playerItem.asset URL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.movieController==nil)
                {
                    self.movieController= [[MPMoviePlayerController alloc] init];
                    [self.movieController.view setFrame: self.view.bounds];
                }
                
                [self.view insertSubview:self.movieController.view atIndex:1];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name: MPMoviePlayerPlaybackDidFinishNotification object: self.movieController];
                //format should be like this:@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0958.mov"
                [self.movieController setContentURL: theURL];
                [self.movieController prepareToPlay];
                [self.movieController play];
                self.playButton.hidden=YES;
            });
        }
    }];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name: MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self.movieController stop];
    
    [self.movieController.view removeFromSuperview];
    //self.movieController = nil;
    self.playButton.hidden=NO;
}

#pragma - private methods

-(void)setCurrentItemView{
    PHAsset *asset=[self.assets objectAtIndex:self.currentIndex];
    self.playButton.hidden=asset.mediaType!=PHAssetMediaTypeVideo;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.view.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        self.LargeImageView.image=result;
        
        NSError *error=[info objectForKey:PHImageErrorKey];
        if (error) {
            NSLog(@"get image error: %@", error.description);
        }

    }];
}

//need to customize subtype
-(CATransition *)getPushTransition{
    CATransition *transition=[CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return transition;
}

@end
