//
//  spgARViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/24/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spgTabBarViewController.h"

@interface spgARViewController : UIViewController <spgScooterPresentationDelegate>

@property (weak, nonatomic) IBOutlet UIView *ARContainerView;

@property (weak, nonatomic) IBOutlet UIView *topControllerView;
@property (weak, nonatomic) IBOutlet UIView *ARInfoView;
@property (weak, nonatomic) IBOutlet UIView *ARListView;
@property (weak, nonatomic) IBOutlet UIView *ARMapView;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *timeLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *temperatureLabel;

//views in infoview
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIView *ARGaugeView;
@property (weak, nonatomic) IBOutlet UIView *realDataView;
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

//views in listview
@property (weak, nonatomic) IBOutlet UIView *listWeatherView;
@property (weak, nonatomic) IBOutlet UIView *listDateView;
@property (weak, nonatomic) IBOutlet UIView *listSpeedView;
@property (weak, nonatomic) IBOutlet UILabel *longDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *captureModeButton;
@property (weak, nonatomic) IBOutlet UIButton *camButton;

- (IBAction)switchCameraMode:(UIButton *)sender;
- (IBAction)switchCam:(id)sender;
- (IBAction)closeClicked:(UIButton *)sender;

-(void)rotateLayout:(BOOL)portrait;

@end
