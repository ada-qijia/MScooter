//
//  spgMomentsPersistence.m
//  mScooterNow
//
//  Created by v-qijia on 1/12/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import "spgMomentsPersistence.h"

@implementation spgMomentsPersistence
  static bool isLoaded;
  static NSMutableArray * moments;

+(NSString *)dataFilePath{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"moments.plist"];
}

//return saved or empty array.
+(NSMutableArray *)getMoments{
    if(!isLoaded)
    {
        isLoaded=true;
        NSString *filePath=[self dataFilePath];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            moments=[[NSMutableArray alloc] initWithContentsOfFile:filePath];
        }
    }
    
    if(moments==nil)
    {
        moments=[NSMutableArray array];
    }
    
    return moments;
}

+(BOOL)saveMoments:(NSArray *) urls{
    if(urls!=nil)
    {
        NSString *filePath=[self dataFilePath];
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
        return [urls writeToFile:filePath atomically:YES];
    }
    return false;
}

@end

