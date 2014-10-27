//
//  spgMScooterUtilities.h
//  mScooterNow
//
//  Created by v-qijia on 10/24/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface spgMScooterUtilities : NSObject

+(void)LogData:(NSData *)data title:(NSString *)title;

+(NSData *)getDataFromByte:(Byte)value;
+(NSData *)getDataFromInt16:(int16_t)value;

@end
