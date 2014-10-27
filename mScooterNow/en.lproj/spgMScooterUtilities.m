//
//  spgMScooterUtilities.m
//  mScooterNow
//
//  Created by v-qijia on 10/24/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgMScooterUtilities.h"

@implementation spgMScooterUtilities

+(void)LogData:(NSData *)data title:(NSString *)title
{
    NSMutableString *mutableString=[[NSMutableString alloc] init];
    Byte *bytes=(Byte *)data.bytes;
    for(int i=0;i<data.length;i++)
    {
        NSString *hex=[NSString stringWithFormat:@"%X", bytes[i]];
        [mutableString appendString:hex];
    }
    
    NSLog(@"%@: %@ \n",title, mutableString);
}

+(NSData *)getDataFromByte:(Byte)value
{
    Byte bytes[]={value};
    NSData *data=[NSData dataWithBytes:bytes length:1];
    return data;
}

+(NSData *)getDataFromInt16:(int16_t)value
{
    NSData *data=[NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

@end
