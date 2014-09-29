//
//  spgPinViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THPinViewController.h"

@interface spgPinViewController : UIViewController<THPinViewControllerDelegate>

@property (nonatomic, assign) BOOL locked;
@property (copy,nonatomic) NSString *correctPin;

- (void)login:(id)sender;
- (void)logout:(id)sender;

@end
