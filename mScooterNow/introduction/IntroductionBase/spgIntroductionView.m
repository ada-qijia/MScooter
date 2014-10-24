//
//  spgIntroductionView.m
//  mScooterNow
//
//  Created by v-qijia on 10/20/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgIntroductionView.h"
#import "spgMScooterDefinitions.h"

@implementation spgIntroductionView

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        [self initializeViewComponents];
    }
    return self;
}

-(void)initializeViewComponents{
    //Background Image View
    self.BackgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.BackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.BackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.BackgroundImageView];
    
    
    //BackgroundColorView
    self.BackgroundColorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.frame.size.width,self.frame.size.height)];
    self.BackgroundColorView.backgroundColor = kBlurTintColor;
    [self addSubview:self.BackgroundColorView];
    
    //Master Scroll View
    self.MasterScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.MasterScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
    self.MasterScrollView.pagingEnabled = YES;
    self.MasterScrollView.delegate = self;
    self.MasterScrollView.showsHorizontalScrollIndicator = NO;
    self.MasterScrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.MasterScrollView];

    //Page Control
    self.PageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.frame.size.width - kPageControlWidth)/2, self.frame.size.height - 100, kPageControlWidth, 37)];
    self.PageControl.currentPage = 0;
    [self.PageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.PageControl];
    
    //bottom button
    self.BottomButton=[[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kBottomButtonHeight, self.frame.size.width, kBottomButtonHeight)];
    self.BottomButton.backgroundColor=ThemeColor;
    [self.BottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.BottomButton.layer setShadowColor:nil];
    self.BottomButton.hidden=YES;
    [self.BottomButton  addTarget:self action:@selector(bottomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.BottomButton];
}

- (IBAction)pageChanged:(UIPageControl *)sender {
    float offsetX=sender.currentPage * self.frame.size.width;
    [self.MasterScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)bottomButtonClicked:(UIButton *)sender
{
    if(self.buttonClicked)
    {
        self.buttonClicked(sender);
    }
}
    
-(void)buildIntroductionWithPanels:(NSArray *)panels
{
    Panels=panels;
    
    //addPanelsToScrollView
    if (Panels && Panels.count > 0)
         {
            self.PageControl.numberOfPages = Panels.count;
            [self buildScrollViewLeftToRight];
        }
        else {
            NSLog(@"You must pass in panels for the introduction view to have content. no panels were found");
        }
}

-(void)buildScrollViewLeftToRight{
    CGFloat panelXOffset = 0;
    for (spgIntroductionPanel* panelView in Panels) {
        panelView.frame = CGRectMake(panelXOffset, 0, self.frame.size.width, self.frame.size.height);
        [self.MasterScrollView addSubview:panelView];
        
        panelXOffset += self.frame.size.width;
    }
    [self.MasterScrollView setContentSize:CGSizeMake(panelXOffset, self.frame.size.height)];
    
    [self animatePanelAtIndex:0];
}

-(void)appendCloseViewAtXIndex:(CGFloat*)xIndex{
    UIView *closeView = [[UIView alloc] initWithFrame:CGRectMake(*xIndex, 0, self.frame.size.width, 400)];
    
    [self.MasterScrollView addSubview:closeView];
    
    *xIndex += self.MasterScrollView.frame.size.width;
}

//Show the information at the given panel with animations
-(void)animatePanelAtIndex:(NSInteger)index{
  
    spgIntroductionPanel* toPanel=Panels[index];
    toPanel.alpha=1;

    /*
    if(Panels.count>index)
    {
        //Hide all views
        for (spgIntroductionPanelViewController *panelView in Panels) {
            panelView.view.alpha = 0;
        }
        
        spgIntroductionPanelViewController * toPanel=Panels[index];
        toPanel.view.alpha=1;
        [toPanel.view setNeedsDisplay];
    }
     */
    
    
/*
    //Animate
    if (Panels.count > index) {
    
        //Animate title and header
        [UIView animateWithDuration:0.3 animations:^{
            if([Panels[index] PanelTitleLabel])
                {
                    [[Panels[index] PanelTitleLabel] setAlpha:1];
                    //[[Panels[index] PanelTitleLabel] setTransform:CGAffineTransformIdentity];
                    
                    [[Panels[index] PanelContentView] setAlpha:1];
                    //[[Panels[index] PanelContentView] setTransform:CGAffineTransformIdentity];
                }
            } completion:^(BOOL finished) {
            //Animate description
            [UIView animateWithDuration:0.3 animations:^{
                [[Panels[index] PanelDescriptionLabel] setAlpha:1];
                //[[Panels[index] PanelDescriptionLabel] setTransform:CGAffineTransformIdentity];         }completion:^(BOOL finished) {
                    if([Panels[index] PanelFooterView])
                    {
                        [[Panels[index] PanelFooterView] setAlpha:1];
                        //[[Panels[index] PanelFooterView] setTransform:CGAffineTransformIdentity];
                    }
                }];
        }];
    }
     */
}

-(void)setBottomButtonHidden:(BOOL)hidden title:(NSString *)title
{
    [self.BottomButton setTitle:title forState:UIControlStateNormal];
    self.BottomButton.hidden=hidden;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.CurrentPanelIndex = scrollView.contentOffset.x/self.MasterScrollView.frame.size.width;
    
    //Assign the last page to be the previous current page
    LastPanelIndex = self.PageControl.currentPage;
   
    //Update Page Control
    self.PageControl.currentPage = self.CurrentPanelIndex;
            
    //Call Back, if applicable
    if (LastPanelIndex != self.CurrentPanelIndex) {
        if ([(id)self.delegate respondsToSelector:@selector(introduction:didChangeToPanel:withIndex:)]) {
                    [self.delegate introduction:self didChangeToPanel:Panels[self.CurrentPanelIndex] withIndex:self.CurrentPanelIndex];
                }
   
        [self animatePanelAtIndex:self.CurrentPanelIndex];
    }
}

//This will handle our changing opacity at the end of the introduction
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.CurrentPanelIndex == (Panels.count - 1)) {
            self.alpha = ((self.MasterScrollView.frame.size.width*(float)Panels.count)-self.MasterScrollView.contentOffset.x)/self.MasterScrollView.frame.size.width;
        }
}

@end
