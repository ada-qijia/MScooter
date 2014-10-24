//
//  spgIntroductionPanel.h
//  mScooterNow
//
//  Created by v-qijia on 10/21/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spgIntroductionPanel : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

+(id)introductionPanel;
+(id)introductionPanel:(UIView *)centerView description:(NSString *)description;
-(void)buildWithContents:(UIView *)centerView description:(NSString *)description;

@end
