//
//  spgModeSettingsViewController.h
//  mScooterNow
//
//  Created by v-qijia on 11/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "spgMScooterUtilities.h"

@interface spgModeSettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *scenarioModeTableView;
- (IBAction)backClicked:(id)sender;

@end
