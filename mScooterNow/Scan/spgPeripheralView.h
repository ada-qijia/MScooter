//
//  spgPeripheralView.h
//  mScooterNow
//
//  Created by v-qijia on 11/6/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface spgPeripheralView : UIView

@property (weak, nonatomic) CBPeripheral *peripheral;
@property float battery;

@end
