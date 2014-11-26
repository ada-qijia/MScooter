//
//  spgScooterPeripheral.m
//  mScooterNow
//
//  Created by v-qijia on 11/18/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgScooterPeripheral.h"

@implementation spgScooterPeripheral

-(id)initWithPeripheral:(CBPeripheral *)peripheral timeArrayCapacity:(NSUInteger) capacity
{
    self=[super init];
    if(self)
    {
        self.Peripheral=peripheral;
        self.RecentTimeArray=[NSMutableArray arrayWithCapacity:capacity];
        
        for(int i=0;i<capacity;i++)
        {
            [self.RecentTimeArray addObject:[NSDate dateWithTimeIntervalSince1970:0]];
        }
        
        self.FlagTag=-1;
    }
    
    return self;
}

@end
