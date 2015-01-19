//
//  spgMomentsPersistence.h
//  mScooterNow
//
//  Created by v-qijia on 1/12/15.
//  Copyright (c) 2015 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface spgMomentsPersistence : NSObject

+(NSMutableArray *)getMoments;
+(BOOL)saveMoments:(NSArray *) urls;

@end
