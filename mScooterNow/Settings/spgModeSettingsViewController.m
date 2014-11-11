//
//  spgModeSettingsViewController.m
//  mScooterNow
//
//  Created by v-qijia on 11/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgModeSettingsViewController.h"

@interface spgModeSettingsViewController ()

@end

@implementation spgModeSettingsViewController
{
    NSArray* scenarioModes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2.jpg"]];
     scenarioModes=[NSArray arrayWithObjects:kScenarioModeCampus,kScenarioModePersonal, nil];
}

//set your prefered/saved scenario mode selected in the tableview.
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *currentMode=[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey];
    if(currentMode)
    {
        NSInteger row= [scenarioModes indexOfObject:currentMode];
        if(row!=NSNotFound)
        {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            [self.scenarioModeTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.scenarioModeTableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryCheckmark;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma table view dataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return scenarioModes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"scenarioModeCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=scenarioModes[indexPath.row];
    cell.textLabel.textColor=[UIColor whiteColor];
    return cell;
}

#pragma table view delegate

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSIndexPath *selectedIndex= [tableView indexPathForSelectedRow];
    if(selectedIndex.row!=indexPath.row)
    {
        [tableView cellForRowAtIndexPath:selectedIndex].accessoryType=UITableViewCellAccessoryNone;
        [tableView deselectRowAtIndexPath:selectedIndex animated:YES];
    }
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryCheckmark;
    
    return indexPath;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *mode=scenarioModes[indexPath.row];
    //save if changed
    if(![mode isEqualToString:[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey]])
    {
        [spgMScooterUtilities savePreferenceWithKey:kMyScenarioModeKey value:mode];
        /*
        //clean saved MyPeripheralID if change to personal mode.
        if([mode isEqualToString:kScenarioModePersonal])
        {
            [spgMScooterUtilities savePreferenceWithKey:kMyPeripheralIDKey value:nil];
        }
         */
    }
}

#pragma - UI interaction

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
