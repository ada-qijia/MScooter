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

+(NSString *)getMyPeripheralID
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *idString= [userDefaults stringForKey:kMyPeripheralIDKey];
    return idString;
}

//save to user defaults
+(void)saveMyPeripheralID:(NSString *)uuid
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uuid forKey:kMyPeripheralIDKey];
    [userDefaults synchronize];
}
@end
