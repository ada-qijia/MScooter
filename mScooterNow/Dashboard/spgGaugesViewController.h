//
//  spgGaugesViewController.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgGaugesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *ARInfoView;
@property (weak, nonatomic) IBOutlet UIView *ARListView;

@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *timeLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *temperatureLabel;

@property (weak, nonatomic) IBOutlet UILabel *longDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end
