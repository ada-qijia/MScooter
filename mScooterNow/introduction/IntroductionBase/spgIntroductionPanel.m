//
//  spgIntroductionPanel.m
//  mScooterNow
//
//  Created by v-qijia on 10/21/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgIntroductionPanel.h"

@implementation spgIntroductionPanel

+(id)introductionPanel
{
    spgIntroductionPanel *panel=[[[NSBundle mainBundle] loadNibNamed:@"spgIntroductionPanel" owner:nil options:nil] lastObject];
    
    if([panel isKindOfClass:[spgIntroductionPanel class]])
    {
        return panel;
    }
    else
    {
        return nil;
    }
}

+(id)introductionPanel:(UIView *)centerView description:(NSString *)description
{
    spgIntroductionPanel *panel=[spgIntroductionPanel introductionPanel];
    if(panel)
    {
        [panel.contentView addSubview:centerView];
        panel.contentView.hidden=!centerView;
        
        panel.descriptionLabel.text=description;
        panel.descriptionLabel.hidden=!description;
    }
    return panel;
}

//change contents after created
-(void)buildWithContents:(UIView *)centerView description:(NSString *)description{
    if(self)
    {
        [self.contentView addSubview:centerView];
        self.contentView.hidden=!centerView;
        
        self.descriptionLabel.text=description;
        self.descriptionLabel.hidden=!description;
    }
}

@end
