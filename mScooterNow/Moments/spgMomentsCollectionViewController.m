//
//  spgMomentsCollectionViewController.m
//  mScooterNow
//
//  Created by v-qijia on 1/21/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgMomentsCollectionViewController.h"


@interface spgMomentsCollectionViewController ()

@property (nonatomic,strong) NSMutableArray *momentGroups;
@property (nonatomic,strong) NSMutableArray *assets;

@end

@implementation spgMomentsCollectionViewController
{
    int presentCount;
}

static NSString * const reuseIdentifier = @"Cell";
static NSString * const headerIdentifier=@"Header";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSMutableArray *momentsArray=[spgMomentsPersistence getMoments];
    NSString *backImg=momentsArray.count==0?@"noMomentBg.png":@"momentsbg.png";
    self.BackgroundImage.image=[UIImage imageNamed:backImg];
    
    //don't reload when no changes.
    if(presentCount==momentsArray.count)
    {return;}
    
    self.assets=[NSMutableArray array];
    
    NSLog(@"Start loading assets...");
    NSMutableArray *notExistMomentsArray=[NSMutableArray array];
    for(NSString *urlStr in momentsArray)
    {
        PHFetchResult *fetchResult=[PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:[NSURL URLWithString:urlStr]] options:nil];
        if(fetchResult.count>0)
        {
            PHAsset *asset= [fetchResult objectAtIndex:0];
            if(asset)
            {
                KeyValuePair *pair=[[KeyValuePair alloc] initWithKey:urlStr value:asset];
                [self.assets addObject:pair];
            }
        }
        else
        {
            [notExistMomentsArray addObject:urlStr];
        }
    }
    
    //delete not exist items
    if(notExistMomentsArray.count>0)
    {
        for(NSString *urlStr in notExistMomentsArray)
        {
          [momentsArray removeObject:urlStr];
        }
        [spgMomentsPersistence saveMoments:momentsArray];
    }
    
    self.momentGroups=[self groupAssetsWithTime:self.assets];
    
    NSLog(@"Finished loading assets...");
    
    [self.collectionView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    presentCount=(int)self.assets.count;
}

-(NSMutableArray *)groupAssetsWithTime:(NSArray *)source{
    NSMutableArray *groupedAssets = [NSMutableArray array];
    for (KeyValuePair *obj in source) {
        PHAsset *asset=(PHAsset *)(obj.value);
        NSDate *creationDate = asset.creationDate;
        
        if(creationDate)
        {
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            //[dateFormatter setDateFormat:@"ss"];
            [dateFormatter setDateFormat:@"yyyy.MM.dd EEEE"];
            NSString *key=[dateFormatter stringFromDate:creationDate];
            
            KeyValuePair *lastPair=groupedAssets.lastObject;
            if([lastPair.key isEqualToString:key])
            {
                NSMutableArray *arr = (NSMutableArray *)lastPair.value;
                [arr addObject:asset];
            }
            else
            {
                NSMutableArray *arr = [NSMutableArray arrayWithObject:asset];
                KeyValuePair *newPair=[[KeyValuePair alloc] initWithKey:key value:arr];
                [groupedAssets addObject:newPair];
            }
        }
    }
    return groupedAssets;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.momentGroups.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    KeyValuePair *pair=self.momentGroups[section];
    return ((NSArray *)pair.value).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    KeyValuePair *pair=self.momentGroups[indexPath.section];
    NSArray *assets= (NSArray *)pair.value;
    PHAsset *asset= assets[indexPath.row];
    
    if(asset)
    {
        UIImageView *imageView=(UIImageView *)[cell.contentView viewWithTag:11];
        UIImageView *videoImageView=(UIImageView *)[cell.contentView viewWithTag:12];
        UILabel *durationLabel=(UILabel *)[cell.contentView viewWithTag:13];
        
        //Image
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(200, 90) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
            imageView.image=result;
            
            NSError *error=[info objectForKey:PHImageErrorKey];
            if (error) {
                NSLog(@"get image error: %@", error.description);
            }
        }];
        
        //asset type
        videoImageView.hidden=asset.mediaType!=PHAssetMediaTypeVideo;
        
        //video duration
        NSTimeInterval interval= asset.duration;
        durationLabel.hidden=interval==0;
        if(interval!=0)
        {
            int hour= (int)(interval/3600);
            int minute=(int)(interval/60)-hour*60;
            int second=(int)interval%60;
            durationLabel.text=[NSString stringWithFormat:@"%02d:%02d",minute,second];
        }
    }
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
    
    KeyValuePair *pair=self.momentGroups[indexPath.section];
    UILabel *dateLable=(UILabel *)[header viewWithTag:1];
    dateLable.text=pair.key;
    
    return header;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    KeyValuePair *pair=self.momentGroups[indexPath.section];
    NSArray *assets= (NSArray *)pair.value;
    PHAsset *asset= assets[indexPath.row];
    
    //get index of the selected asset
    int index=0;
    for (KeyValuePair *p in self.assets) {
        if(p.value==asset)
        {
            break;
        }
        index++;
    }
    
    spgAssetViewController *assetVC=[[spgAssetViewController alloc] initWithNibName:@"spgAssetViewController" bundle:nil];
    assetVC.assets = self.assets;
    assetVC.currentIndex = index;
    assetVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:assetVC animated:YES completion:nil];
}

@end
