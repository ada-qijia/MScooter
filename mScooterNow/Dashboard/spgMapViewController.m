//
//  spgMapViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgMapViewController.h"
#import "spgMScooterDefinitions.h"

@interface spgMapViewController ()

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
    
    self.mapView.mapType=MKMapTypeStandard;
    CLLocationCoordinate2D centerLocation=CLLocationCoordinate2DMake(39.980777, 116.309108);
    MKCoordinateRegion mapRegion=MKCoordinateRegionMakeWithDistance(centerLocation, 2000, 2000);
    [self.mapView setRegion:mapRegion animated:YES];
    
    self.mapView.pitchEnabled=false;
    self.mapView.rotateEnabled=false;
    self.mapView.showsUserLocation=YES;
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

#pragma mark - map delegate methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
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
