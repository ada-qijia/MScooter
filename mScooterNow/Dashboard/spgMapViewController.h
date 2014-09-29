//
//  spgMapViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface spgMapViewController : UIViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
