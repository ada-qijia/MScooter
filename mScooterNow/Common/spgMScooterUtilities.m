//
//  spgMScooterUtilities.m
//  mScooterNow
//
//  Created by v-qijia on 10/28/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgMScooterUtilities.h"

@implementation spgMScooterUtilities

+(void)LogData:(NSData *)data title:(NSString *)title
{
    NSString *hexString=[spgMScooterUtilities castDataToHexString:data];
    NSLog(@"%@: %@ \n",title, hexString);
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

+(NSData *)getDataFromString:(NSString *)value startIndex:(int)index length:(int)length
{
    if(value.length<=index)
    {
        return nil;
    }
    
    NSUInteger maxlength=MIN(value.length-index, length);
    NSRange range=NSMakeRange(index, maxlength);
    NSString *str=[value substringWithRange:range];
    NSData *data = [str dataUsingEncoding: NSUTF8StringEncoding];
    
    return data;
}

//2 bytes data
+(float)castSpeedToRealValue:(NSData *)data
{
    float realSpeed=0;
    int16_t i=0;
    [data getBytes:&i length:sizeof(i)];
    
    if(i>245)
    {
        realSpeed=27;
    }
    else if(i>=226 && i<=245)
    {
        realSpeed=25;
    }
    else if(i>=201&&i<=225)
    {
        realSpeed=23;
    }
    else if(i>=180&&i<=200)
    {
        realSpeed=20;
    }
    else if(i>=160&&i<=179)
    {
        realSpeed=17;
    }
    else if(i>=140&&i<=159)
    {
        realSpeed=15;
    }
    else if(i>120&&i<140)
    {
        realSpeed=5*(i-115)/15.0+10;
    }
    else if(i>=110&&i<=120)
    {
        realSpeed=10;
    }
    else if(i>60&&i<110)
    {
        realSpeed=5*(i-55)/60.0+5;
    }
    else if(i>=50&&i<=60)
    {
        realSpeed=5;
    }
    else if(i>20 &&i<50)
    {
        realSpeed=4*(i-15)/40.0+1;
    }
    else if(i>=10&&i<=20)
    {
        realSpeed=1;
    }
    
    return realSpeed;
}

//2 bytes data
+(float)castBatteryToPercent:(NSData *)data
{
    int16_t i=0;
    [data getBytes:&i length:sizeof(i)];
    float realV=i/511.0*3.2*16;//voltage
    float realBattery=0;
    if(realV>=42)
    {
        realBattery=100;
    }
    else if(realV<=30)
    {
        realBattery=5;
    }
    else
    {
        realBattery=(realV-30)*95/12.0+5;
    }
    
    return realBattery;
}

+(int)castMileageToInt:(NSData *)data
{
    int32_t i=0;
    [data getBytes:&i length:sizeof(i)];
    return i;
}

+(PowerState)castDataToPowerState:(NSData *)data
{
    Byte *bytes=(Byte *)[data bytes];
    PowerState currentState=(PowerState)bytes[1];
    return currentState;
}

+(BatteryState)castDataToBatteryState:(NSData *)data
{
    Byte *bytes=(Byte *)[data bytes];
    BatteryState currentState=(BatteryState)bytes[0];
    return currentState;
}

+(NSString *)castDataToHexString:(NSData *)data
{
    NSMutableString *mutableString=[[NSMutableString alloc] init];
    Byte *bytes=(Byte *)data.bytes;
    for(int i=0;i<data.length;i++)
    {
        NSString *hex=[NSString stringWithFormat:@"%02X", bytes[i]];
        [mutableString appendString:hex];
    }
    return [NSString stringWithString:mutableString];
}

+(NSString *)getBatteryImageFromValue:(float)value
{
    int level= value/20;
    level=level>4?4:level;
    return [NSString stringWithFormat:@"battery%d@2x.png",level+1];
}

#pragma - local save

+(NSString *)getPreferenceWithKey:(NSString *) key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *idString= [userDefaults stringForKey:key];
    return idString;
}

//save to user defaults
+(void)savePreferenceWithKey:(NSString *)key value:(id)value
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

@end



@implementation KeyValuePair

-(id)initWithKey:(NSString *) key value:(NSObject *) value
{
    self=[super init];
    self.key=key.copy;
    self.value=value;
    return self;
}

@end
