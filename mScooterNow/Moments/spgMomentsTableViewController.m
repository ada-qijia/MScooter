//
//  spgMomentsTableViewController.m
//  mScooterNow
//
//  Created by v-qijia on 1/12/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgMomentsTableViewController.h"
#import "spgAssetViewController.h"

@interface spgMomentsTableViewController ()

@property (nonatomic,strong) NSMutableArray *assets;

@end

@implementation spgMomentsTableViewController
{
    MPMoviePlayerController* theMovie;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"momentsbg@2x.png"]];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(30,0,0,0)];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    theMovie =[[MPMoviePlayerController alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.assets=[NSMutableArray array];
    
    NSLog(@"Start loading assets...");
    NSMutableArray *urls=[NSMutableArray array];
    for(NSString *urlStr in [spgMomentsPersistence getMoments])
    {
        [urls addObject:[NSURL URLWithString:urlStr]];
    }
    
    PHFetchResult *fetchResult=[PHAsset fetchAssetsWithALAssetURLs:urls options:nil];
    for(int i=0;i<fetchResult.count;i++)
    {
        PHAsset *asset= [fetchResult objectAtIndex:i];
        if(asset)
        {
            [self.assets addObject:asset];
        }
    }
    NSLog(@"Finished loading assets...");
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset= self.assets[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MomentsCell" forIndexPath:indexPath];
    if(asset)
    {
        UILabel *dateLabel=(UILabel *)[cell.contentView viewWithTag:10];
        UILabel *dayLabel=(UILabel *)[cell.contentView viewWithTag:11];
        UIImageView *imageView=(UIImageView *)[cell.contentView viewWithTag:12];
        UILabel *durationLabel=(UILabel *)[cell.contentView viewWithTag:13];
        
        //video duration
        NSTimeInterval interval= asset.duration;
        durationLabel.hidden=interval==0;
        if(interval!=0)
        {
            int hour= (int)(interval/3600);
            int minute=(int)(interval/60)-hour*60;
            int second=(int)interval%60;
            durationLabel.text=[NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
        }
        
        //date
        NSDate *date= asset.creationDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateFormatter setDateFormat:@"MMM dd"];
        dateLabel.text =[dateFormatter stringFromDate:date];
        
        //week day
        [dateFormatter setDateFormat:@"EEEE"];
        dayLabel.text =[dateFormatter stringFromDate:date];
        
        //Image
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(200, 90) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
            imageView.image=result;
            
            NSError *error=[info objectForKey:PHImageErrorKey];
            if (error) {
                NSLog(@"get image error: %@", error.description);
            }
        }];
    }
    
    return cell;
}

#pragma - tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    spgAssetViewController *assetVC=[[spgAssetViewController alloc] initWithNibName:@"spgAssetViewController" bundle:nil];
    assetVC.assets=self.assets;
    assetVC.currentIndex= indexPath.row;
    assetVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:assetVC animated:YES completion:nil];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
