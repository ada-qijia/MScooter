//
//  spgTabBarViewController.m
//  mScooterNow
//
//  Created by v-qijia on 10/16/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgTabBarViewController.h"
#import "spgMomentsCollectionViewController.h"
#import "spgDashboardViewController.h"
#import "spgSettingsViewController.h"

@interface spgTabBarViewController ()

@property (strong,nonatomic) spgBLEService *bleService;

@end

@implementation spgTabBarViewController
{
    UIViewController* selectedViewController;
    NSArray* tabViewControllers;
    
    CLLocationManager *locationManager;
    NSTimer *usageTimer;
    float battery;
    float speed;
    int milage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bleService=[spgBLEService sharedInstance];
    
    NSInteger lastState = [[spgMScooterUtilities getPreferenceWithKey:kLastPowerStateKey] integerValue];
    self.currentPowerState=lastState;
    self.currentBatteryState=BatteryStateUnDefined;
    
    spgMomentsCollectionViewController* firstChildVC=[self.storyboard instantiateViewControllerWithIdentifier:@"spgMomentsVCID"];
    spgDashboardViewController* secondChildVC = [self.storyboard instantiateViewControllerWithIdentifier:@"spgDashboardVCID"];
    //spgSettingsViewController* thirdChildVC=[self.storyboard instantiateViewControllerWithIdentifier:@"spgSettingsVCID"];
    UINavigationController *thirdChildVC=[self.storyboard instantiateViewControllerWithIdentifier:@"spgSettingsNavID"];
    tabViewControllers=[NSArray arrayWithObjects:firstChildVC,secondChildVC,thirdChildVC,nil];
    
    [self setSelectedTabIndex:1];
    
    locationManager=[[CLLocationManager alloc] init];
    [self startUploadUsage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bleService.peripheralDelegate=self;
}

//when tabbar is hidden in spgARViewController, this will be called.
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    
}

#pragma - supported orientation

//set only the AR view support landscape orientation.
-(NSUInteger)supportedInterfaceOrientations
{
    /*
     UIButton *dashboardBtn=(UIButton *)[self.BottomBar viewWithTag:2];
     if(dashboardBtn.selected)
     {
     return UIInterfaceOrientationMaskAllButUpsideDown;
     }
     else*/
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGSize tabItemSize=CGSizeMake(27, 27);
    
    UIView *centerView=(UIView *)self.view.subviews[0];
    centerView.autoresizingMask=UIViewAutoresizingNone;
    centerView.frame=CGRectMake(0, 0, size.width, size.height);
    
    if(size.width<size.height)
    {
        self.BottomBar.frame=CGRectMake(0, size.height-49, size.width, 49);
        self.momentsBtn.frame=CGRectMake(40, 10,tabItemSize.width,tabItemSize.height);
        self.dashboardBtn.frame=CGRectMake(147, 10, tabItemSize.width, tabItemSize.height);
        self.meBtn.frame=CGRectMake(245, 10, tabItemSize.width, tabItemSize.height);
        self.momentsBadge.frame=CGRectMake(58, 5, 18, 18);
    }else
    {
        self.BottomBar.frame=CGRectMake(size.width-49, 0, 49, size.height);
        self.momentsBtn.frame=CGRectMake(10, 245,tabItemSize.width,tabItemSize.height);
        self.dashboardBtn.frame=CGRectMake(10, 147, tabItemSize.width, tabItemSize.height);
        self.meBtn.frame=CGRectMake(10, 40, tabItemSize.width, tabItemSize.height);
        self.momentsBadge.frame=CGRectMake(5, 58, 18, 18);
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

-(void)viewWillLayoutSubviews
{
    NSLog(@"tabbar: %@",self.view);
}

#pragma mark - spgBLEService delegate

-(void)centralManager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral
{
    //send Identify
    NSString *uniqueIdentifier= [UIDevice currentDevice].identifierForVendor.UUIDString;
    if(uniqueIdentifier)
    {
        NSData *data=[spgMScooterUtilities getDataFromString:uniqueIdentifier startIndex:0 length:18];
        
        //write may fail because characteristic not found.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL writeSuccess=[[spgBLEService sharedInstance] IdentifyPhone:data];
            while (!writeSuccess) {
                [NSThread sleepForTimeInterval:1];
                writeSuccess= [[spgBLEService sharedInstance] IdentifyPhone:data];
            }
        });
    }
    
    //notify
    if([self.scooterPresentationDelegate respondsToSelector:@selector(updateConnectionState:)])
    {
        [self.scooterPresentationDelegate updateConnectionState:YES];
    }
    
    //save scooter name
    [spgMScooterUtilities savePreferenceWithKey:kScooterNameKey value:peripheral.name];
}

-(void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if([self.scooterPresentationDelegate respondsToSelector:@selector(updateConnectionState:)])
    {
        [self.scooterPresentationDelegate updateConnectionState:NO];
    }
    
    [self updateSettings];
}

-(void)speedValueUpdated:(NSData *)speedData
{
    //[spgMScooterUtilities LogData:speedData title:@"Speed"];
    
    float realSpeed=0;
    int16_t i=0;
    [speedData getBytes:&i length:sizeof(i)];
    
    if(i>245)
    {
        realSpeed=27;
    }
    else if(i>=226 && i<=245)
    {
        realSpeed=25;
    }
    else if(i>=201&&i<=225)
    {
        realSpeed=23;
    }
    else if(i>=180&&i<=200)
    {
        realSpeed=20;
    }
    else if(i>=160&&i<=179)
    {
        realSpeed=17;
    }
    else if(i>=140&&i<=159)
    {
        realSpeed=15;
    }
    else if(i>120&&i<140)
    {
        realSpeed=5*(i-115)/15.0+10;
    }
    else if(i>=110&&i<=120)
    {
        realSpeed=10;
    }
    else if(i>60&&i<110)
    {
        realSpeed=5*(i-55)/60.0+5;
    }
    else if(i>=50&&i<=60)
    {
        realSpeed=5;
    }
    else if(i>20 &&i<50)
    {
        realSpeed=4*(i-15)/40.0+1;
    }
    else if(i>=10&&i<=20)
    {
        realSpeed=1;
    }
    
    speed=realSpeed;
    //update speed
    
    if([self.scooterPresentationDelegate respondsToSelector:@selector(updateSpeed:)])
    {
        [self.scooterPresentationDelegate updateSpeed:realSpeed];
    }
}

-(void)batteryValueUpdated:(NSData *)batteryData
{
    //update battery state
    NSString *hexString=[spgMScooterUtilities castDataToHexString:batteryData];
    NSString *type=[hexString substringFromIndex:2];
    
    //65280=#ff00
    if([type isEqualToString: @"FF"])
    {
        BatteryState newBatteryState=[[hexString substringToIndex:2] isEqualToString:@"01"]?BatteryStateOn:BatteryStateOff;
        self.currentBatteryState=newBatteryState;
        if([self.scooterPresentationDelegate respondsToSelector:@selector(batteryStateChanged:)])
        {
            [self.scooterPresentationDelegate batteryStateChanged:newBatteryState];
        }
    }
    else
    {
        //[spgMScooterUtilities LogData:batteryData title:@"Battery"];
        float realBattery=[spgMScooterUtilities castBatteryToPercent:batteryData];
        battery=realBattery;
        
        //update battery
        if([self.scooterPresentationDelegate respondsToSelector:@selector(updateBattery:)])
        {
            //float realBattery=[spgMScooterUtilities castBatteryToPercent:batteryData];
            [self.scooterPresentationDelegate updateBattery:realBattery];
        }
    }
    
    //NSLog(@"Batt: %@",hexString);
}

-(void)cameraTriggered:(SBSCameraCommand) commandType
{
    if([self.scooterPresentationDelegate respondsToSelector:@selector(cameraTriggered:)])
    {
        [self.scooterPresentationDelegate cameraTriggered:commandType];
    }
}

-(void)modeChanged
{
    if([self.scooterPresentationDelegate respondsToSelector:@selector(modeChanged)])
    {
        [self.scooterPresentationDelegate modeChanged];
    }
}

-(void)mileageUpdated:(NSData *)mileage
{
    //unit m
    int value=[spgMScooterUtilities castMileageToInt:mileage];
    milage=value;
    
    if([self.scooterPresentationDelegate respondsToSelector:@selector(updateMileage:)])
    {
        [self.scooterPresentationDelegate updateMileage:value];
    }
}

-(void)passwordCertificationReturned:(CBPeripheral *)peripheral result:(BOOL)correct
{
    if([self.scooterPresentationDelegate respondsToSelector:@selector(updateCertifyState:)])
    {
        [self.scooterPresentationDelegate updateCertifyState:correct];
    }
}

-(void)identifyReturned:(CBPeripheral *)peripheral result:(NSString *) result
{
    if([result isEqualToString:kACKIdentifyContinueResponse])
    {
        NSString *uniqueIdentifier= [UIDevice currentDevice].identifierForVendor.UUIDString;
        NSData *data=[spgMScooterUtilities getDataFromString:uniqueIdentifier startIndex:18 length:18];
        [[spgBLEService sharedInstance] IdentifyPhone:data];
    }
    else
    {
        if([self.scooterPresentationDelegate respondsToSelector:@selector(updateCertifyState:)])
        {
            [self.scooterPresentationDelegate updateCertifyState:[result isEqualToString:kACKCorrectResponse]];
        }
        
        [self updateSettings];
    }
}

-(void)powerStateReturned:(CBPeripheral *)peripheral result:(NSData *) data
{
    PowerState state=[spgMScooterUtilities castDataToPowerState:data];
    
    self.currentPowerState=state;
    NSNumber *stateNum= [NSNumber numberWithInteger:state];
    [spgMScooterUtilities savePreferenceWithKey:kLastPowerStateKey value:stateNum];
    
    if([self.scooterPresentationDelegate respondsToSelector:@selector(powerStateReturned:result:)])
    {
        [self.scooterPresentationDelegate powerStateReturned:peripheral result:state];
    }
}

#pragma - interface methods

-(void)showDashboardGauge
{
    UIButton *dashboardBtn=(UIButton *)[self.BottomBar viewWithTag:2];
    [self TabItemClicked:dashboardBtn];
    
    spgDashboardViewController *dashboardVC = (spgDashboardViewController *)selectedViewController;
    [dashboardVC showGauge];
}

#pragma - UI update

-(void)updateSettings
{
    UIButton *settingBtn=(UIButton *)[self.BottomBar viewWithTag:3];
    if(settingBtn.selected)
    {
        UINavigationController *navController=(UINavigationController *)selectedViewController;
        spgSettingsViewController *settingsVC = navController.childViewControllers[0];
        [settingsVC updateSwitch];
    }
}

//make radio button effect
- (IBAction)TabItemClicked:(UIButton *)sender {
    [self setSelectedTabIndex:sender.tag-1];
    if(sender.tag==1)
    {
        [self setBadge:nil];
    }
}

-(void)setSelectedTabIndex:(NSInteger) index
{
    for (UIButton *btn in self.BottomBar.subviews) {
        if(btn!=nil && btn.tag>0)
        {
            btn.selected=btn.tag==index+1;
        }
    }
    
    [self ShowCenterView:index];
}


-(void)ShowCenterView:(NSInteger) selectedIndex
{
    UIViewController *newSelectedVC=tabViewControllers[selectedIndex];
    if(selectedViewController!=newSelectedVC)
    {
        /*
         //force moments and me orientation to portrait
         if(selectedIndex!=1)
         {
         NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
         [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
         }*/
        
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        [self addChildViewController:newSelectedVC];
        [self.view insertSubview:newSelectedVC.view atIndex:0];
        
        selectedViewController=tabViewControllers[selectedIndex];
    }
}

-(void)setBadge:(NSString *)value
{
    int num=[value intValue];
    if(num!=0)
    {
        self.momentsBadge.text=value;
        self.momentsBadge.hidden=NO;
    }
    else
    {
        self.momentsBadge.text=nil;
        self.momentsBadge.hidden=YES;
    }
}

#pragma mark - Post usage data

-(void)startUploadUsage
{
    if(usageTimer==nil)
    {
        usageTimer=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:usageTimer forMode:NSRunLoopCommonModes];
    }
    [usageTimer fire];
}

-(void)timerTicked:(NSTimer *)timer
{
    //connected,upload all
    bool connected= [spgBLEService sharedInstance].peripheral.state==CBPeripheralStateConnected;
    if(connected && [spgMScooterUtilities UserID]!=0)
    {
        CLLocation *loc= locationManager.location;
        NSDictionary *usageParam=[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:battery],@"Battery",
                                  [NSNumber numberWithFloat:speed],@"Speed",
                                  [NSNumber numberWithInt:milage],@"Mileage",
                                  [NSString stringWithFormat:@"%f,%f",loc.coordinate.longitude,loc.coordinate.latitude],@"Location",
                                  nil];
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:usageParam options:kNilOptions error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self uploadUsage:jsonString];
        });
    }
}

-(void)uploadUsage:(NSString *)param
{
    NSMutableDictionary *scooterUsage=[spgMScooterUtilities getScooterUsage:3];
    if(param)
    {
        [scooterUsage setValue:param forKey:@"UsageParam1"];
    }
    
    NSError *error;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:scooterUsage options:kNilOptions error:&error];
    //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if(error==nil)
    {
        //url request
        NSString *path=[NSString stringWithFormat:@"%@/api/scooterUsages",kServerUrlBase];
        NSURL *url=[NSURL URLWithString:path];
        NSMutableURLRequest *urlRequest=[NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest addValue:@"application/json"forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:jsonData];
        
        NSURLSession *sharedSession=[NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask=[sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(error==nil)
            {
                NSString *text=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"upload usage success: %@", text);
            }
            else
            {
                NSLog(@"upload usage failed!");
            }
        }];
        
        [dataTask resume];
    }
}

@end
