//
//  spgARViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/24/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgARViewController.h"
#import "spgMScooterDefinitions.h"
#import "spgCamViewController.h"
#import "WMGaugeView.h"
#import "spgARGaugesViewController.h"

@interface spgARViewController ()

@end

@implementation spgARViewController
{
    NSTimer *timer;
    spgCamViewController *videoCaptureVC;
    DashboardMode currentMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    videoCaptureVC= [self.childViewControllers objectAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateConnectedUIState];
   
    //update time and temperature
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
    
    [videoCaptureVC stopVideoCapture];
    
    [timer invalidate];
}

//new layout after orientation changed.
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    spgCamViewController *camVC= self.childViewControllers[0];
    [camVC rotateLayout];
    
    self.ARContainerView.frame=CGRectMake(0, 0, size.width, size.height);
    if(size.width>size.height)
    {
        self.ARListView.frame=CGRectMake(40, 0, 460, 320);
        self.listWeatherView.frame=CGRectMake(300, 180, 80, 40);
        self.listDateView.frame=CGRectMake(300, 225, 160, 40);
        self.listSpeedView.frame=CGRectMake(300, 270, 160, 40);
        self.ARInfoView.frame=self.ARListView.frame;
        self.realDataView.frame=CGRectMake(330, 15, 120, 40);
        self.ARGaugeView.frame=CGRectMake(70, 120, 320, 192);
        
        self.ARMapView.frame=CGRectMake(40, 0, 480, 320);
        self.mapView.frame=CGRectMake(280, 0, 200, 320);
    }
    else
    {
        self.ARListView.frame=CGRectMake(0, 40, 320, 460);
        self.listWeatherView.frame=CGRectMake(215, 15, 80, 40);
        self.listDateView.frame=CGRectMake(25, 370, 160, 40);
        self.listSpeedView.frame=CGRectMake(25, 420, 160, 40);
        self.ARInfoView.frame=self.ARListView.frame;
        self.realDataView.frame=CGRectMake(10, 15, 120, 40);
        self.ARGaugeView.frame=CGRectMake(0, 270, 320, 192);
        
        self.ARMapView.frame=CGRectMake(0, 40, 320, 480);
        self.mapView.frame=CGRectMake(0, 280, 320, 200);
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

#pragma - spgScooterPresentationDelegate

-(void)updateConnectionState:(BOOL) connected
{
    [self updateConnectedUIState];
}

-(void)updateSpeed:(float)speed
{
    WMGaugeView *speedView = (WMGaugeView *)[self.ARGaugeView viewWithTag:41];
    [speedView setValue:speed animated:YES duration:0.3];
    
    self.speedLabel.text=[NSString stringWithFormat:@"%02.f",speed];
}

-(void)updateBattery:(float)battery
{
    WMGaugeView *batteryView = (WMGaugeView *)[self.ARGaugeView viewWithTag:42];
    [batteryView setValue:battery animated:YES duration:0.3];
}

-(void)cameraTriggered:(SBSCameraCommand)commandType
{
    switch (commandType) {
     case SBSCameraCommandTakePhoto:
            [videoCaptureVC snapStillImage];
            break;
     case SBSCameraCommandStartRecordVideo:
            [videoCaptureVC startVideoCapture];
            break;
     case SBSCameraCommandStopRecordVideo:
            [videoCaptureVC stopVideoCapture];
            break;
     default:
            break;
    }
}

#pragma - public method

- (void)switchCam {
    [videoCaptureVC changeCamera];
}

#pragma - update UI

-(void)rotateLayout:(BOOL)portrait
{
}

-(void)updateConnectedUIState
{
    CBPeripheralState currentState=[[spgBLEService sharedInstance] peripheral].state;
    
    spgARGaugesViewController *gaugesVC= self.childViewControllers[1];
    [gaugesVC setGaugesEnabled:currentState==CBPeripheralStateConnected];
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
@end
