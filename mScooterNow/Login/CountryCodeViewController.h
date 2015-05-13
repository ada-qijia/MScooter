//
//  CountryCodeViewController.h
//  mScooterNow
//
//  Created by v-qijia on 4/10/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SMS_SDK/CountryAndAreaCode.h>

@protocol CountryCodeViewControllerDelegate <NSObject>

-(void)setCountryCodeData:(CountryAndAreaCode *)data;

@end


@interface CountryCodeViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>
{
    BOOL isSearching;
}

@property (nonatomic, strong)  UITableView *table;
@property (nonatomic, strong)  UISearchBar *search;
@property (nonatomic, strong) NSDictionary *allNames;
@property (nonatomic, strong) NSMutableDictionary *names;
@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong) id<CountryCodeViewControllerDelegate> delegate;

//- (void)resetSearch;
//- (void)handleSearchForTerm:(NSString *)searchTerm;
-(void)setAreaArray:(NSMutableArray*)array;

@end
