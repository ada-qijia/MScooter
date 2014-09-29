//
//  spgARGaugesViewController.m
//  mScooterNow
//
//  Created by v-qijia on 9/18/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgARGaugesViewController.h"
#import "WMGaugeView.h"
#import "spgMScooterDefinitions.h"

@interface spgARGaugesViewController ()

@property (weak, nonatomic) IBOutlet WMGaugeView *speedGaugeView;
@property (weak, nonatomic) IBOutlet WMGaugeView *batteryGaugeView;

@end

@implementation spgARGaugesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.speedGaugeView.unitOfMeasurementFont=[UIFont boldSystemFontOfSize:0.07];
    self.speedGaugeView.unitOfMeasurement=@"km/h";
    self.speedGaugeView.showUnitOfMeasurement=YES;
    self.speedGaugeView.minValue=0.0;
    self.speedGaugeView.maxValue = 40.0;
    self.speedGaugeView.scaleDivisions = 8;
    self.speedGaugeView.scaleSubdivisions = 5;
    self.speedGaugeView.scaleStartAngle = -45;
    self.speedGaugeView.scaleEndAngle = 225;
    self.speedGaugeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    self.speedGaugeView.showScaleShadow = YES;
    self.speedGaugeView.scaleFont =[UIFont boldSystemFontOfSize:0.07];// [UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    self.speedGaugeView.scalesubdivisionsAligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.speedGaugeView.scaleSubdivisionsWidth = 0.002;
    self.speedGaugeView.scaleSubdivisionsLength = 0.04;
    self.speedGaugeView.scaleDivisionsWidth = 0.007;
    self.speedGaugeView.scaleDivisionsLength = 0.07;
    self.speedGaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    self.speedGaugeView.needleWidth = 0.012;
    self.speedGaugeView.needleHeight = 0.4;
    self.speedGaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
    self.speedGaugeView.needleScrewRadius = 0.05;
    self.speedGaugeView.showScale=YES;
    self.speedGaugeView.scalePosition=0.05;
    self.speedGaugeView.scaleDivisionColor=[UIColor whiteColor];
    self.speedGaugeView.scaleSubDivisionColor=[UIColor whiteColor];
    
    self.batteryGaugeView.unitOfMeasurementFont=[UIFont boldSystemFontOfSize:0.09];
    self.batteryGaugeView.unitOfMeasurement=@"%";
    self.batteryGaugeView.showUnitOfMeasurement=YES;
    self.batteryGaugeView.minValue=0.0;
    self.batteryGaugeView.maxValue = 100.0;
    self.batteryGaugeView.scaleDivisions = 10;
    self.batteryGaugeView.scaleSubdivisions = 5;
    self.batteryGaugeView.scaleStartAngle = -180;
    self.batteryGaugeView.scaleEndAngle = 180;
    self.batteryGaugeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    self.batteryGaugeView.showScaleShadow = YES;
    self.batteryGaugeView.scaleFont = [UIFont boldSystemFontOfSize:0.09];//[UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    self.batteryGaugeView.scalesubdivisionsAligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.batteryGaugeView.scaleSubdivisionsWidth = 0.002;
    self.batteryGaugeView.scaleSubdivisionsLength = 0.04;
    self.batteryGaugeView.scaleDivisionsWidth = 0.007;
    self.batteryGaugeView.scaleDivisionsLength = 0.07;
    self.batteryGaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    self.batteryGaugeView.needleWidth = 0.012;
    self.batteryGaugeView.needleHeight = 0.4;
    self.batteryGaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
    self.batteryGaugeView.needleScrewRadius = 0.05;
    self.batteryGaugeView.showScale=YES;
    self.batteryGaugeView.scalePosition=0.04;
    self.batteryGaugeView.scaleDivisionColor=[UIColor whiteColor];
    self.batteryGaugeView.scaleSubDivisionColor=[UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
