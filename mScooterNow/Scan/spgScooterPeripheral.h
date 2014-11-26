//
//  spgScooterPeripheral.h
//  mScooterNow
//
//  Created by v-qijia on 11/18/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgMScooterCommon.h"

@interface spgScooterPeripheral : NSObject

@property CBPeripheral *Peripheral;
@property (strong,nonatomic) NSMutableArray *RecentTimeArray;
@property (strong,nonatomic) NSData *BatteryData;
@property (nonatomic) BLEDeviceState CurrentState;
@property (nonatomic) int FlagTag;

-(id)initWithPeripheral:(CBPeripheral *)peripheral timeArrayCapacity:(NSUInteger) capacity;

@end
