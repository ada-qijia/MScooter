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
+(NSData *)getDataFromString:(NSString *)value length:(int)length;

+(float)castSpeedToRealValue:(NSData *)data;
+(float)castBatteryToPercent:(NSData *)data;
+(int)castMileageToInt:(NSData *)data;
+(PowerState)castDataToPowerState:(NSData *)data;

+(NSString *)castDataToHexString:(NSData *)data;

+(NSString *)getBatteryImageFromValue:(float)value;

+(NSString *)getPreferenceWithKey:(NSString *) key;
+(void)savePreferenceWithKey:(NSString *)key value:(id)value;

@end