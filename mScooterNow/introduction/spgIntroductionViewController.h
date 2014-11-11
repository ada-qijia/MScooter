//
//  spgIntroductionViewController.h
//  mScooterNow
//
//  Created by v-qijia on 10/20/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spgIntroductionView.h"

@interface spgIntroductionViewController : UIViewController <spgIntroductionDelegate>

@property (nonatomic) BOOL isRelay;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backClicked:(id)sender;

@end
