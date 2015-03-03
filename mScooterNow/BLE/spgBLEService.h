//
//  spgBLEService.h
//  SPGScooterRemote
//
//  Created by v-qijia on 9/12/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "spgMScooterCommon.h"

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
-(void)centralManager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral;
-(void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
-(void)centralManagerDidUpdateState:(CBCentralManager *)central;

@end


#pragma mark - manipulate one peripheral delegate

@protocol spgBLEServicePeripheralDelegate <NSObject,spgBLEServiceDiscoverPeripheralsDelegate>

@required

@optional

-(void)speedValueUpdated:(NSData *)speedData;
-(void)batteryValueUpdated:(NSData *)batteryData;
-(void)cameraTriggered:(SBSCameraCommand)commandType;
-(void)mileageUpdated:(NSData *)mileage;
-(void)modeChanged;
-(void)autoPoweredOff;
-(void)passwordCertificationReturned:(CBPeripheral *)peripheral result:(BOOL) correct;
-(void)identifyReturned:(CBPeripheral *)peripheral result:(NSString *) result;
-(void)powerStateReturned:(CBPeripheral *)peripheral result:(NSData *) data;
//-(void)batteryStateReturned:(BOOL)success;

@end


#pragma mark - interface

@interface spgBLEService : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

+(spgBLEService *)sharedInstance;

@property (nonatomic, weak) id<spgBLEServiceDiscoverPeripheralsDelegate> discoverPeripheralsDelegate;
@property (nonatomic, weak) id<spgBLEServicePeripheralDelegate> peripheralDelegate;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong,nonatomic) CBPeripheral *peripheral;
//contains bool value
@property NSNumber *isCertified;

-(id)initWithDelegates:(id<spgBLEServiceDiscoverPeripheralsDelegate>)delegate peripheralDelegate:(id<spgBLEServicePeripheralDelegate>) peripheralDelegate;
-(void)startScan;
-(void)stopScan;
-(void)connectPeripheral;
-(void)disConnectPeripheral;
-(void)writePower:(NSData *) data;
-(BOOL)writePassword:(NSData *)data;
-(BOOL)IdentifyPhone:(NSData *)data;

-(void)clean;
@end
