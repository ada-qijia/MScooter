//
//  spgModeSettingsViewController.m
//  mScooterNow
//
//  Created by v-qijia on 11/10/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgModeSettingsViewController.h"
#import "spgTabBarViewController.h"

@interface spgModeSettingsViewController ()

@end

@implementation spgModeSettingsViewController
{
    NSArray* scenarioModes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGradient.jpg"]];
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

NSIndexPath *willSelectIndexPath;
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndex= [tableView indexPathForSelectedRow];
    if(selectedIndex.row!=indexPath.row)
    {
        willSelectIndexPath=indexPath;
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to change mode? This will disconnect your current scooter." delegate:self  cancelButtonTitle:@"CANCEL" otherButtonTitles:@"YES",nil];
        [alertView show];
    }
    
    return nil;
}

-(void)ChangeSelectionToIndexPath:(NSIndexPath *)indexPath
{
    NSString *mode=scenarioModes[indexPath.row];
    //save if changed
    if(![mode isEqualToString:[spgMScooterUtilities getPreferenceWithKey:kMyScenarioModeKey]])
    {
        [spgMScooterUtilities savePreferenceWithKey:kMyScenarioModeKey value:mode];
    }
    
    //disconnect & go back to dashboard gauge
    [[spgBLEService sharedInstance] clean];
    spgTabBarViewController *tabBarVC=(spgTabBarViewController *)self.presentingViewController;
    [tabBarVC showDashboardGauge];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma - alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *selectedIndex= [self.scenarioModeTableView indexPathForSelectedRow];
    if(buttonIndex==1&&willSelectIndexPath)
    {
        [self.scenarioModeTableView cellForRowAtIndexPath:selectedIndex].accessoryType=UITableViewCellAccessoryNone;
        [self.scenarioModeTableView deselectRowAtIndexPath:selectedIndex animated:YES];
        [self.scenarioModeTableView cellForRowAtIndexPath:willSelectIndexPath].accessoryType=UITableViewCellAccessoryCheckmark;
        
        [self ChangeSelectionToIndexPath:willSelectIndexPath];
    }
    
    willSelectIndexPath=nil;
}

#pragma - UI interaction

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
