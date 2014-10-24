//
//  spgIntroductionView.h
//  mScooterNow
//
//  Created by v-qijia on 10/20/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "spgIntroductionPanel.h"

#define BlurTintColor [UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:1];

static UIColor *kBlurTintColor = nil;
static const CGFloat kPageControlWidth = 148;
static const CGFloat kLeftRightSkipPadding = 10;
static const CGFloat kBottomButtonHeight = 50;
static UIFont *kSkipButtonFont = nil;

@class spgIntroductionView;

typedef void(^ButtonClickedCallback)(UIButton *);

#pragma - spgIntroductionDelegate

@protocol spgIntroductionDelegate
@optional
-(void)introduction:(spgIntroductionView *)introductionView didChangeToPanel:(spgIntroductionView *)panel withIndex:(NSInteger)panelIndex;
@end


#pragma - spgIntroductionView

@interface spgIntroductionView : UIView<UIScrollViewDelegate>
{
    NSArray *Panels;
    NSInteger LastPanelIndex;
}

@property (weak) id<spgIntroductionDelegate> delegate;

@property (nonatomic, retain) UIView *BackgroundColorView;
@property (retain, nonatomic) UIImageView *BackgroundImageView;
@property (retain, nonatomic) UIScrollView *MasterScrollView;
@property (retain, nonatomic) UIPageControl *PageControl;
@property (retain, nonatomic) UIButton *BottomButton;
@property (nonatomic, assign) NSInteger CurrentPanelIndex;

@property (nonatomic, copy) ButtonClickedCallback buttonClicked;

//Construction Methods
-(void)buildIntroductionWithPanels:(NSArray *)panels;

-(void)setBottomButtonHidden:(BOOL)hidden title:(NSString *)title;

@end
