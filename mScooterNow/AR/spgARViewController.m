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
    ARMode currentMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *horizontalLeftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalLeftSwipe:)];
    horizontalLeftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:horizontalLeftSwipe];
    
    UISwipeGestureRecognizer *horizontalRightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontalRightSwipe:)];
    horizontalRightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:horizontalRightSwipe];
    
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
    
    self.tabBarController.tabBar.hidden=YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [videoCaptureVC stopVideoCapture];
    
    [timer invalidate];
    
    self.tabBarController.tabBar.hidden=NO;
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
            self.captureModeButton.selected=YES;
            [videoCaptureVC snapStillImage];
            break;
     case SBSCameraCommandStartRecordVideo:
            self.captureModeButton.selected=NO;
            [videoCaptureVC startVideoCapture];
            break;
     case SBSCameraCommandStopRecordVideo:
            self.captureModeButton.selected=NO;
            [videoCaptureVC stopVideoCapture];
            break;
     default:
            break;
    }
}

-(void)modeChanged
{
    [self switchARMode:YES];
}

#pragma - UI interaction

-(void)gotoARMode:(ARMode)toMode
{
    if(currentMode!=toMode)
    {
        currentMode=toMode;
  
        UIView *modeView=[self getViewOfARMode:toMode];
        NSArray* modeViews=[NSArray arrayWithObjects:self.ARInfoView,self.ARListView,self.ARMapView, nil];
        for (UIView* modeV in modeViews) {
            modeV.hidden=!(modeV==modeView);
        }
        
        BOOL fullScreen=!(toMode==ARModeMap);
        spgCamViewController *camVC= self.childViewControllers[0];
        [camVC showInFullScreen:fullScreen];
    }
}

//between video and photo
- (IBAction)switchCameraMode:(UIButton *)sender {
    self.captureModeButton.selected=!self.captureModeButton.selected;
    [videoCaptureVC switchMode:self.captureModeButton.selected];
}

- (IBAction)switchCam:(id)sender {
    [videoCaptureVC changeCamera];
}

- (IBAction)closeClicked:(UIButton *)sender {
    spgTabBarViewController *tabBarVC= (spgTabBarViewController *)self.tabBarController;
    tabBarVC.selectedIndex= tabBarVC.lastSelectedIndex;
}

#pragma mark - gesture methods

-(void)reportHorizontalLeftSwipe:(UIGestureRecognizer *)recognizer
{
    [self switchARMode:YES];
}

-(void)reportHorizontalRightSwipe:(UIGestureRecognizer *)recognizer
{
    [self switchARMode:NO];
}

-(void)switchARMode:(BOOL) next
{
    int modeCount=4;
    UIView *currentView=[self getViewOfARMode:currentMode];
    
    ARMode toMode=next?(currentMode+1)%modeCount:(currentMode-1+modeCount)%modeCount;
    UIView *nextView=[self getViewOfARMode:toMode];
  
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype =next? kCATransitionFromRight:kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [nextView.layer addAnimation:transition forKey:nil];
    [currentView.layer addAnimation:transition forKey:nil];
    
    currentView.hidden=YES;
    nextView.hidden=NO;
    
    currentMode=toMode;
    
    BOOL fullScreen=!(toMode==ARModeMap);
    spgCamViewController *camVC= self.childViewControllers[0];
    [camVC showInFullScreen:fullScreen];
}

-(UIView *)getViewOfARMode:(ARMode) mode
{
    switch (mode) {
        case ARModeCool:
            return self.ARInfoView;
        case ARModeList:
            return self.ARListView;
        case ARModeMap:
            return self.ARMapView;
        case ARModeNormal:
            return nil;
        default:
            return nil;
    }
}

#pragma - update UI

-(void)rotateLayout:(BOOL)portrait
{
    spgCamViewController *camViewController = self.childViewControllers[0];
    if(portrait)
    {
        self.view.frame=CGRectMake(0, 0, 320, 568);
        
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
        self.view.frame=CGRectMake(0, 0, 568, 320);
        
        self.ARInfoView.frame=CGRectMake(0, 0,510, 320);
        self.realDataView.frame=CGRectMake(60, 10, 150, 40);
        self.mapView.frame=CGRectMake(390, 10, 110, 110);
        self.ARGaugeView.frame=CGRectMake(90, 126, 320, 192);
        
        self.listWeatherView.frame=CGRectMake(420, 10, 110, 110);
        self.listDateView.frame=CGRectMake(75, 270, 160, 40);
        self.listSpeedView.frame=CGRectMake(310, 270, 160, 40);
    }
    self.ARContainerView.frame=self.view.frame;
    self.ARListView.frame=self.ARInfoView.frame;
    
    UIInterfaceOrientation toOrientation=portrait?UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeLeft;
    [camViewController rotateLayout:toOrientation];
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
