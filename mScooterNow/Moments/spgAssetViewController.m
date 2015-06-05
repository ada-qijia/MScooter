//
//  spgAssetViewController.m
//  mScooterNow
//
//  Created by v-qijia on 1/13/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgAssetViewController.h"
#import "spgMomentsPersistence.h"
#import "WechatActivity.h"

@interface spgAssetViewController ()

@end

@implementation spgAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self RegisterGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setCurrentItemView];
}

#pragma - mark gesture
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

#pragma - mark play video

- (void)playVideo
{
    KeyValuePair *pair=(KeyValuePair *)[self.assets objectAtIndex:self.currentIndex];
    PHAsset *asset= (PHAsset *)(pair.value);
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if ([playerItem.asset isKindOfClass:AVURLAsset.class])
        {
            NSURL *theURL = [(AVURLAsset *)playerItem.asset URL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.movieController==nil)
                {
                    self.movieController= [[MPMoviePlayerController alloc] init];
                    [self.movieController.view setFrame: self.view.bounds];
                    self.movieController.controlStyle=MPMovieControlStyleFullscreen;
                }
                
                [self.ItemView insertSubview:self.movieController.view atIndex:3];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name: MPMoviePlayerPlaybackDidFinishNotification object: self.movieController];
                //format should be like this:@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0958.mov"
                [self.movieController setContentURL: theURL];
                [self.movieController prepareToPlay];
                [self.movieController play];
                
                self.deleteButton.hidden=YES;
            });
        }
    }];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    [self stopPlayMovie];
}

-(void)stopPlayMovie
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self.movieController stop];
    
    [self.movieController.view removeFromSuperview];
    self.deleteButton.hidden=NO;
}

#pragma - mark private methods

-(void)RegisterGesture
{
    UISwipeGestureRecognizer *horizontalLeftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalLeftSwipe:)];
    horizontalLeftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:horizontalLeftSwipe];
    
    UISwipeGestureRecognizer *horizontalRightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalRightSwipe:)];
    horizontalRightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontalRightSwipe];
    
    UITapGestureRecognizer *singleFingerTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

-(void)setCurrentItemView{
    if(self.assets.count>self.currentIndex)
    {
        KeyValuePair *pair=(KeyValuePair *)[self.assets objectAtIndex:self.currentIndex];
        PHAsset *asset= (PHAsset *)(pair.value);
        self.playButton.hidden=asset.mediaType!=PHAssetMediaTypeVideo;
        self.shareButton.hidden=asset.mediaType!=PHAssetMediaTypeImage;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:self.view.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
            self.LargeImageView.image=result;
            
            NSError *error=[info objectForKey:PHImageErrorKey];
            if (error) {
                NSLog(@"get image error: %@", error.description);
            }
        }];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//need to customize subtype
-(CATransition *)getPushTransition{
    CATransition *transition=[CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return transition;
}

#pragma mark - UI interaction

- (IBAction)PlayClicked:(id)sender {
    [self playVideo];
}

- (IBAction)ShareClicked:(UIButton *)sender {
    //NSString *title= @"wonderful neezza moments";
    UIImage *img=self.LargeImageView.image;
    NSArray *activityItems=@[img];
    
    WechatSessionActivity *wechatSession=[[WechatSessionActivity alloc] init];
    WechatTimelineActivity *wechatTimeline=[[WechatTimelineActivity alloc] init];
    NSArray *activities=@[wechatSession,wechatTimeline];
    UIActivityViewController *vc=[[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
    //only remain sina weibo
    vc.excludedActivityTypes=@[UIActivityTypePostToFacebook,
                               UIActivityTypePostToFlickr,
                               UIActivityTypePostToTencentWeibo,
                               UIActivityTypePostToTwitter,
                               UIActivityTypePostToVimeo,
                               UIActivityTypeMessage,
                               UIActivityTypeMail,
                               UIActivityTypePrint,
                               UIActivityTypeCopyToPasteboard,
                               UIActivityTypeAssignToContact,
                               UIActivityTypeSaveToCameraRoll,
                               UIActivityTypeAddToReadingList,
                               UIActivityTypeAirDrop];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)DeleteClicked:(UIButton *)sender {
    KeyValuePair *pair=(KeyValuePair *)[self.assets objectAtIndex:self.currentIndex];
    NSString *assetUrl=pair.key;
    PHAsset *asset=(PHAsset *)(pair.value);
    
    //delete from photos library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:[NSArray arrayWithObject:asset]];
    } completionHandler:^(BOOL success, NSError *error) {
        
        NSString *result=success?@"success":@"failed";
        NSLog(@"delete photo/video %@ %@",assetUrl, result);
        
        if(success)
        {
            //remove from persistence.
            NSMutableArray *momentsArray=[spgMomentsPersistence getMoments];
            if([momentsArray containsObject:assetUrl])
            {
                [momentsArray removeObject:assetUrl];
                [spgMomentsPersistence saveMoments:momentsArray];
                
                //update current page
                [self.assets removeObjectAtIndex:self.currentIndex];
                self.currentIndex=self.currentIndex%self.assets.count;
                [self setCurrentItemView];
            }
        }
    }];
}

- (IBAction)CloseClicked:(UIButton *)sender {
    [self stopPlayMovie];
}

@end
