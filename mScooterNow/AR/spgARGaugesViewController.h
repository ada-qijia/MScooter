//
//  spgARGaugesViewController.h
//  mScooterNow
//
//  Created by v-qijia on 9/18/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgARGaugesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *dashboardCircleImage;

-(void)setGaugesEnabled:(BOOL)enabled;

@end
