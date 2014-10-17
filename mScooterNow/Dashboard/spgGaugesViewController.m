//
//  spgGaugesViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgGaugesViewController.h"
#import "WMGaugeView.h"
#import "spgMScooterDefinitions.h"
#import "spgCamViewController.h"

@interface spgGaugesViewController ()

@property (weak, nonatomic) IBOutlet WMGaugeView *speedGaugeView;
@property (weak, nonatomic) IBOutlet WMGaugeView *batteryGaugeView;
@property (weak, nonatomic) IBOutlet WMGaugeView *distanceGaugeView;

@end

@implementation spgGaugesViewController
{
    NSTimer *timer;
}

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateDateTime];
    
    UILabel *tempLabel=self.temperatureLabel[0];
    if([tempLabel.text isEqual:@"-"])
        {
            [self updateTemperature];
        }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
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
{
    spgCamViewController *camViewController = self.childViewControllers[0];
    if(portrait)
    {
        self.ARView.frame=CGRectMake(0, 0, 320, 568);
        
        self.ARInfoView.frame=CGRectMake(0, 0,320, 510);
        self.realDataView.frame=CGRectMake(10, 60, 150, 40);
        self.mapView.frame=CGRectMake(200, 70, 110, 110);
        self.ARGaugeView.frame=CGRectMake(0, 320, 320, 192);
        
        self.listWeatherView.frame=CGRectMake(215, 55, 80, 40);
        self.listDateView.frame=CGRectMake(25, 415, 160, 40);
        self.listSpeedView.frame=CGRectMake(25, 470, 160, 40);
    }
    else
    {
        self.ARView.frame=CGRectMake(0, 0, 568, 320);
        
        self.ARInfoView.frame=CGRectMake(0, 0,510, 320);
        self.realDataView.frame=CGRectMake(60, 10, 150, 40);
        self.mapView.frame=CGRectMake(390, 10, 110, 110);
        self.ARGaugeView.frame=CGRectMake(90, 126, 320, 192);
        
        self.listWeatherView.frame=CGRectMake(420, 10, 110, 110);
        self.listDateView.frame=CGRectMake(75, 270, 160, 40);
        self.listSpeedView.frame=CGRectMake(310, 270, 160, 40);
    }
        self.ARContainerView.frame=self.ARView.frame;
        self.ARListView.frame=self.ARInfoView.frame;
    
    UIInterfaceOrientation toOrientation=portrait?UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft;
    [camViewController rotateLayout:toOrientation];
}

#pragma - date time utilities

-(void)updateDateTime
{
   timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
   [timer fire];
}

-(void)timerTicked:(NSTimer *)timer
{
    NSDate *date=[NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //week day
    [dateFormatter setDateFormat:@"EEE"];
    NSString *formattedWeekDay=[dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"MMMd"];
    NSString *formattedDate=[dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *formattedTime=[dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd EEEE"];
    NSString *formattedLongDate=[dateFormatter stringFromDate:date];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.weekDayLabel.text=[formattedWeekDay uppercaseString];
        self.dateLabel.text=[formattedDate uppercaseString];
        self.longDateLabel.text=[formattedLongDate uppercaseString];
        
        for(UILabel* label in self.timeLabel)
        {
            label.text=formattedTime;
        }
    });
}

#pragma - weather

-(void)updateTemperature
{
    NSString *path=[NSString stringWithFormat:@"http://www.weather.com.cn/data/sk/%@.html",kBeijingCityID];
    NSURL *url=[NSURL URLWithString:path];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError)
        {
            NSLog(@"Get temperature error:%@",connectionError.description);
        }
        else
        {
            NSString *temp=[self parseTemperatureResult:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                for(UILabel* tempLabel in self.temperatureLabel)
                {
                    tempLabel.text=temp;
                }
            });
        }
    }];
}
     
-(NSString *)parseTemperatureResult:(NSData *)data
{
    NSError *error=nil;
    NSDictionary *parsedObject=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error==nil)
    {
        NSDictionary *detail=[parsedObject valueForKey:@"weatherinfo"];
        NSString *temp=[detail valueForKey:@"temp"];
        return [NSString stringWithFormat:@"%@°C",temp];
    }
    return @"-";
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
