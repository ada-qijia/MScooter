//
//  spgStickyCollectionViewFlowLayout.m
//  mScooterNow
//
//  Created by v-qijia on 1/22/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgStickyCollectionViewFlowLayout.h"

@implementation spgStickyCollectionViewFlowLayout
{
    NSMutableArray *headerTops;
}

static NSString * const decorationKindIdentifier = @"SideDecoration";


-(void)prepareLayout
{
    [super prepareLayout];
    
    [self registerNib:[UINib nibWithNibName:@"spgSideDecoration" bundle:nil] forDecorationViewOfKind:decorationKindIdentifier];
    
    //save locations
    headerTops=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.0]];
    for (int i=0; i<[self.collectionView numberOfSections]; i++) {
        NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:i];
        NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:i];
        UICollectionViewLayoutAttributes *lastCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
        float top=CGRectGetMaxY(lastCellAttrs.frame)+self.sectionInset.bottom;
        [headerTops addObject:[NSNumber numberWithFloat:top]];
    }
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView * const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;
    
    NSMutableArray *decorationPaths=[NSMutableArray array];
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            //reset header position
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
            
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            UICollectionViewLayoutAttributes *lastCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
            
            CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
            CGPoint origin = layoutAttributes.frame.origin;
            
            origin.y = MIN(
                           MAX(
                               contentOffset.y,
                               (CGRectGetMinY(firstCellAttrs.frame) - headerHeight - self.sectionInset.top)
                               ),
                           (CGRectGetMaxY(lastCellAttrs.frame) - headerHeight)//+ self.sectionInset.bottom
                           );
            
            layoutAttributes.zIndex = 1024;
            layoutAttributes.frame = (CGRect){
                .origin = origin,
                .size = layoutAttributes.frame.size
            };
            
            //add decoration
            NSIndexPath* indexPath=[NSIndexPath indexPathForItem:numberOfItemsInSection inSection:section];
            [decorationPaths addObject:indexPath];
        }
    }
    
    for (NSIndexPath *indexPath in decorationPaths) {
        [answer addObject:[self layoutAttributesForDecorationViewOfKind:decorationKindIdentifier atIndexPath:indexPath]];
    }
    
    return answer;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
     float headerTop=[headerTops[indexPath.section] floatValue];
     float y=headerTop+self.headerReferenceSize.height;
     float height=[headerTops[indexPath.section+1] floatValue]-headerTop-self.headerReferenceSize.height;
    
    UICollectionViewLayoutAttributes *att=[UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationKindIdentifier withIndexPath:indexPath];
    att.frame=CGRectMake(0,y, 5, height);
    return att;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end
