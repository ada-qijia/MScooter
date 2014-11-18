//
//  spgScooterPeripheral.h
//  mScooterNow
//
//  Created by v-qijia on 11/18/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spgScooterPeripheral : NSObject

@property (strong,nonatomic) NSMutableArray *RecentTimeArray;
@property (strong,nonatomic) NSData *BatteryData;
@property (nonatomic) int LastPosition;

@end
