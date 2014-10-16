//
//  spgBLEService.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/12/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger, SBSCameraCommand){
    SBSCameraCommandTakePhoto,
    SBSCameraCommandStartRecordVideo,
    SBSCameraCommandStopRecordVideo,
    SBSCameraCommandNotValid
};

#pragma mark - discoverPeripherals delegate

@protocol spgBLEServiceDiscoverPeripheralsDelegate <NSObject>

@optional

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
-(void)centralManagerDidUpdateState:(CBCentralManager *)central;

@end


#pragma mark - manipulate one peripheral delegate

@protocol spgBLEServicePeripheralDelegate <NSObject>

@required

@optional

-(void)speedValueUpdated:(NSData *)speedData;
-(void)batteryValueUpdated:(NSData *)batteryData;
-(void)cameraTriggered:(SBSCameraCommand)commandType;
-(void)modeChanged;
-(void)autoPoweredOff;
-(void)powerCharacteristicFound;
-(void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
-(void)centralManager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral;

@end


#pragma mark - interface

@interface spgBLEService : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, weak) id<spgBLEServiceDiscoverPeripheralsDelegate> discoverPeripheralsDelegate;
@property (nonatomic, weak) id<spgBLEServicePeripheralDelegate> peripheralDelegate;
@property (strong, nonatomic) CBCentralManager *centralManager;

-(id)initWithDelegates:(id<spgBLEServiceDiscoverPeripheralsDelegate>)delegate peripheralDelegate:(id<spgBLEServicePeripheralDelegate>) peripheralDelegate;
-(void)startScan;
-(void)stopScan;
-(void)connectPeripheral:(CBPeripheral *)peripheral;
-(void)disConnectPeripheral:(CBPeripheral *)peripheral;
-(void)writePower:(CBPeripheral *)peripheral value:(NSData *) data;

@end
