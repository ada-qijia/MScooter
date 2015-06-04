//
//  spgProfileItemViewController.m
//  mScooterNow
//
//  Created by v-qijia on 5/25/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgProfileItemViewController.h"
#import "spgMyProfileViewController.h"

@interface spgProfileItemViewController ()

@end

@implementation spgProfileItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked)];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked)];
    
    self.ContentField.text=self.value;
    [self.ContentField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneClicked
{
    if(![self.ContentField.text isEqualToString:self.value])
    {
        NSUInteger count=self.navigationController.viewControllers.count;
        spgMyProfileViewController *myProfileVC = self.navigationController.viewControllers[count-2];
        
        if([self.title isEqualToString:@"Name"])
        {
            [myProfileVC setNickname:self.ContentField.text];
        }
        else if([self.title isEqualToString:@"Email"])
        {
            [myProfileVC setEmail:self.ContentField.text];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
