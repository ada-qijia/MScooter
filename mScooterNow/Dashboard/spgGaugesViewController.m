//
//  spgGaugesViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgGaugesViewController.h"

@interface spgGaugesViewController ()

@end

@implementation spgGaugesViewController

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.jpg"]];
    
    self.speedGaugeView.unitOfMeasurementFont=[UIFont boldSystemFontOfSize:0.07];
    self.speedGaugeView.unitOfMeasurement=@"km/h";
    self.speedGaugeView.showUnitOfMeasurement=YES;
    self.speedGaugeView.minValue=0.0;
    self.speedGaugeView.maxValue = 40.0;
    self.speedGaugeView.scaleDivisions = 8;
    self.speedGaugeView.scaleSubdivisions = 5;
    self.speedGaugeView.scaleStartAngle = 45;
    self.speedGaugeView.scaleEndAngle = 315;
    self.speedGaugeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    self.speedGaugeView.showScaleShadow = YES;
    self.speedGaugeView.scaleFont =[UIFont boldSystemFontOfSize:0.05];// [UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    self.speedGaugeView.scalesubdivisionsAligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.speedGaugeView.scaleSubdivisionsWidth = 0.002;
    self.speedGaugeView.scaleSubdivisionsLength = 0.03;
    self.speedGaugeView.scaleDivisionsWidth = 0.007;
    self.speedGaugeView.scaleDivisionsLength = 0.05;
    self.speedGaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    self.speedGaugeView.needleWidth = 0.012;
    self.speedGaugeView.needleHeight = 0.4;
    self.speedGaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
    self.speedGaugeView.needleScrewRadius = 0.05;
    self.speedGaugeView.showScale=YES;
    self.speedGaugeView.scalePosition=0.05;
    self.speedGaugeView.scaleDivisionColor=[UIColor whiteColor];
    self.speedGaugeView.scaleSubDivisionColor=[UIColor whiteColor];
    
    [self setBatteryStyle:self.batteryGaugeView];
    [self setBatteryStyle:self.distanceGaugeView];
    self.distanceGaugeView.unitOfMeasurement=@"km";
}

-(void)setBatteryStyle:(WMGaugeView *)gaugeView
{
    gaugeView.unitOfMeasurementFont=[UIFont boldSystemFontOfSize:0.09];
    gaugeView.unitOfMeasurement=@"%";
    gaugeView.showUnitOfMeasurement=YES;
    gaugeView.minValue=0.0;
    gaugeView.maxValue = 100.0;
    gaugeView.scaleDivisions = 10;
    gaugeView.scaleSubdivisions = 5;
    gaugeView.scaleStartAngle = -180;
    gaugeView.scaleEndAngle = 180;
    gaugeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    gaugeView.scaleFont = [UIFont boldSystemFontOfSize:0.0];//[UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    gaugeView.scalesubdivisionsAligment = WMGaugeViewSubdivisionsAlignmentCenter;
    gaugeView.scaleSubdivisionsWidth = 0.002;
    gaugeView.scaleSubdivisionsLength = 0.04;
    gaugeView.scaleDivisionsWidth = 0.007;
    gaugeView.scaleDivisionsLength = 0.07;
    gaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    gaugeView.needleWidth = 0.012;
    gaugeView.needleHeight = 0.4;
    gaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
    gaugeView.needleScrewRadius = 0.05;
    gaugeView.showScale=YES;
    gaugeView.scalePosition=0.04;
    gaugeView.scaleDivisionColor=[UIColor whiteColor];
    gaugeView.scaleSubDivisionColor=[UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - update UI

-(void)rotateLayout:(BOOL)portrait
{}

-(void)setGaugesEnabled:(BOOL)enabled
{
    [self.view viewWithTag:31].hidden=!enabled;
    [self.view viewWithTag:32].hidden=!enabled;
    [self.view viewWithTag:33].hidden=!enabled;
}

-(void)setBatteryLow:(BOOL)low
{
    NSString *imgName=low?@"batteryLowBg.png":@"batteryBg.png";
    self.batteryBgImage.image=[UIImage imageNamed:imgName];
    [self.view viewWithTag:32].hidden=low;
    [self.view viewWithTag:33].hidden=low;
}

@end
