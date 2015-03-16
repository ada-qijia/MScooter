///
//  spgMapViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgMapViewController.h"
#import "spgMScooterDefinitions.h"
#import "spgMScooterCommon.h"

@interface spgMapViewController ()

@property(retain,nonatomic) CLLocationManager *locationManager;

@end

@implementation spgMapViewController

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
    
    //set mapView
    self.mapView.delegate=self;
    self.mapView.pitchEnabled=false;
    self.mapView.rotateEnabled=false;
    self.mapView.mapType=MKMapTypeStandard;
    
    //set locationManager
    self.locationManager=[[CLLocationManager alloc] init];
    
    if(IS_OS_8_OR_LATER && [CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if([CLLocationManager authorizationStatus]>=kCLAuthorizationStatusAuthorized)
    {
        self.mapView.showsUserLocation=YES;
    }
    
    //set mapview initial center
    CLLocationCoordinate2D centerLocation=self.locationManager.location? self.locationManager.location.coordinate:CLLocationCoordinate2DMake(39.980777, 116.309108);
    MKCoordinateRegion mapRegion=MKCoordinateRegionMakeWithDistance(centerLocation, 2000, 2000);
    [self.mapView setRegion:mapRegion animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.mapView.frame=CGRectMake(0, 0, size.width, size.height);
}

#pragma mark - map delegate methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D coordinate=userLocation.location.coordinate;
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *render=[[MKPolylineRenderer alloc] initWithOverlay:overlay];
        render.strokeColor=[[UIColor blueColor] colorWithAlphaComponent:0.7];
        render.lineWidth=4;
        
        return render;
    }
    else
    {
        return nil;
    }
}

@end
