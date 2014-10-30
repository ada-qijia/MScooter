//
//  spgMScooterUtilities.h
//  mScooterNow
//
//  Created by v-qijia on 10/28/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "spgMScooterDefinitions.h"

@interface spgMScooterUtilities : NSObject

+(void)LogData:(NSData *)data title:(NSString *)title;

+(NSData *)getDataFromByte:(Byte)value;
+(NSData *)getDataFromInt16:(int16_t)value;

+(float)castSpeedToRealValue:(NSData *)data;
+(float)castBatteryToPercent:(NSData *)data;

+(NSString *)castDataToHexString:(NSData *)data;

+(NSString *)getMyPeripheralID;
+(void)saveMyPeripheralID:(NSString *)uuid;

@end
