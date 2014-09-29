//
//  spgPinViewController.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/11/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgPinViewController.h"
#import "spgMScooterDefinitions.h"

static NSUInteger const THNumberOfPinEntries = 6;

@interface spgPinViewController ()

@property (assign,nonatomic) NSUInteger remainingPinEntries;

@end

@implementation spgPinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.correctPin= @"1234";
    //self.locked=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (! self.locked) {
        [self showPinViewAnimated:NO];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

/*
-(void)viewWillAppear:(BOOL)animated
{
    if(self.locked)
    {
        [self login:nil];
    }
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

-(void)setLocked:(BOOL)locked
{
    _locked=locked;
    if(locked)
    {
        self.remainingPinEntries=THNumberOfPinEntries;
    }
}

#pragma mark -UI

- (void)showPinViewAnimated:(BOOL)animated
{
    THPinViewController *pinViewController = [[THPinViewController alloc] initWithDelegate:self];
    pinViewController.promptTitle = @"PASSWORD";
    //UIColor *darkBlueColor = [UIColor colorWithRed:0.012f green:0.071f blue:0.365f alpha:1.0f];
    pinViewController.promptColor = [UIColor whiteColor];
    pinViewController.view.tintColor = ThemeColor;
    
    // for a solid background color, use this:
    pinViewController.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    // for a translucent background, use this:
    //self.view.tag = THPinViewControllerContentViewTag;
    //self.modalPresentationStyle = UIModalPresentationCurrentContext;
    pinViewController.translucentBackground = NO;
    
    [self presentViewController:pinViewController animated:animated completion:nil];
}


#pragma mark - User Interaction

- (void)login:(id)sender
{
    [self showPinViewAnimated:YES];
}

- (void)logout:(id)sender
{
    self.locked = YES;
}

#pragma mark - THPinViewControllerDelegate

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController
{
    return 4;
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin
{
    if ([pin isEqualToString:self.correctPin]) {
        return YES;
    } else {
        self.remainingPinEntries--;
        return NO;
    }
}

- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController
{
    return (self.remainingPinEntries > 0);
}

- (void)incorrectPinEnteredInPinViewController:(THPinViewController *)pinViewController
{
    if (self.remainingPinEntries > THNumberOfPinEntries / 2) {
        return;
    }
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"Incorrect Password"
                               message:(self.remainingPinEntries == 1 ?
                                        @"You can try again once." :
                                        [NSString stringWithFormat:@"You can try again %lu times.",
                                         (unsigned long)self.remainingPinEntries])
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController
{
    self.locked = NO;
}

- (void)pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:(THPinViewController *)pinViewController
{
    self.locked = YES;
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"Access Denied"
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController
{
    if (! self.locked) {
        [self logout:self];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
