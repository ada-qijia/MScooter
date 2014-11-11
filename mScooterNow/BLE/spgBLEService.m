//
//  spgBLEService.m
//  SPGScooterRemote
//
//  Created by v-qijia on 9/12/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#import "spgBLEService.h"
#import "spgMScooterDefinitions.h"

#define CBUUID(s) [CBUUID UUIDWithString:s];

@implementation spgBLEService
{
    NSArray *interestedServices;
    CBCharacteristic *powerCharacteristic;
    CBCharacteristic *passwordCharacteristic;
}

static spgBLEService *sharedInstance=nil;

+(spgBLEService *)sharedInstance
{
    if(!sharedInstance)
    {
        sharedInstance=[[super alloc] init];
    }
    
    return sharedInstance;
}

- (id)initWithDelegates:(id<spgBLEServiceDiscoverPeripheralsDelegate>)delegate peripheralDelegate:(id<spgBLEServicePeripheralDelegate>) peripheralDelegate
{
    self =[spgBLEService sharedInstance];
    
    self.discoverPeripheralsDelegate=delegate;
    self.peripheralDelegate=peripheralDelegate;
    self.centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    //initilize interested service
    CBUUID *speedServiceUUID=CBUUID(kSpeedCharacteristicUUID);
    CBUUID *batteryServiceUUID=CBUUID(kBatteryCharacteristicUUID);
    CBUUID *cameraServiceUUID=CBUUID(kCameraServiceUUID);
    CBUUID *powerServiceUUID=CBUUID(kPowerServiceUUID);
    CBUUID *modeServiceUUID=CBUUID(kModeServiceUUID);
    interestedServices=@[speedServiceUUID,batteryServiceUUID,cameraServiceUUID,modeServiceUUID,powerServiceUUID];
    
    return self;
}

#pragma mark - Bluetooth manipulation

-(void)startScan
{
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    }
}

-(void)stopScan
{
    [self.centralManager stopScan];
}

-(void)connectPeripheral
{
    if(self.centralManager!=nil && self.peripheral!=nil)
    {
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
}

-(void)disConnectPeripheral
{
    if(self.centralManager!=nil && self.peripheral!=nil)
    {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

-(void)writePower:(NSData *) data
{
    if (self.peripheral && powerCharacteristic) {
        [self.peripheral writeValue:data forCharacteristic:powerCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

-(void)writePassword:(NSData *) data
{
    if (self.peripheral && passwordCharacteristic) {
        [self.peripheral writeValue:data forCharacteristic:passwordCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - central manager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManagerDidUpdateState:)])
    {
        [self.discoverPeripheralsDelegate centralManagerDidUpdateState:self.centralManager];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSRange range= [peripheral.name rangeOfString:kScooterDeviceName options:NSCaseInsensitiveSearch];
    if(range.location!=NSNotFound||[peripheral.name hasPrefix:kScooterStationPrefix])
    {
        if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)])
        {
            [self.discoverPeripheralsDelegate centralManager:self.centralManager didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connected peripheral: %@",peripheral.name);
    
    peripheral.delegate=self;
    
    [peripheral discoverServices:nil];//interestedServices];
    
    if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManager:connectPeripheral:)])
    {
        [self.discoverPeripheralsDelegate centralManager:central connectPeripheral:peripheral];
    }
    
    if([self.peripheralDelegate respondsToSelector:@selector(centralManager:connectPeripheral:)])
    {
        [self.peripheralDelegate centralManager:central connectPeripheral:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManager:disconnectPeripheral:error:)])
    {
        [self.discoverPeripheralsDelegate centralManager:central disconnectPeripheral:peripheral error:error];
    }
    
    if([self.peripheralDelegate respondsToSelector:@selector(centralManager:disconnectPeripheral:error:)])
    {
        [self.peripheralDelegate centralManager:central disconnectPeripheral:peripheral error:error];
    }
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManager:disconnectPeripheral:error:)])
    {
        [self.discoverPeripheralsDelegate centralManager:central disconnectPeripheral:peripheral error:error];
    }
    
    if([self.peripheralDelegate respondsToSelector:@selector(centralManager:disconnectPeripheral:error:)])
    {
        [self.peripheralDelegate centralManager:central disconnectPeripheral:peripheral error:error];
    }
}

#pragma mark - peripheral delegate

//discover characteristic for interested service.
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for(CBService *service in peripheral.services)
    {
        NSString *uuid=[service.UUID UUIDString];
        //NSLog(@"Service: %@", uuid);
        
        CBUUID *characteristicUUID=nil;
        if([uuid isEqualToString:kSpeedServiceUUID])
        {
            characteristicUUID=[CBUUID UUIDWithString:kSpeedCharacteristicUUID];
        }
        else if([uuid isEqualToString:kBatteryServiceUUID])
        {
            characteristicUUID=[CBUUID UUIDWithString:kBatteryCharacteristicUUID];
        }
        else if([uuid isEqualToString:kCameraServiceUUID])
        {
            characteristicUUID=CBUUID(kCameraCharacteristicUUID);
        }
        else if([uuid isEqualToString:kPowerServiceUUID])
        {
            //discover password
            CBUUID *characteristicUUID0=CBUUID(kPasswordCharacteristicUUID);
            CBUUID *characteristicUUID1=CBUUID(kPowerCharacteristicUUID);
            [peripheral  discoverCharacteristics:@[characteristicUUID0, characteristicUUID1] forService:service];
        }
        else if([uuid isEqualToString:kModeServiceUUID])
        {
            characteristicUUID=CBUUID(kModeCharateristicUUID);
        }
        
        if(characteristicUUID)
        {
            [peripheral  discoverCharacteristics:@[characteristicUUID] forService:service];
        }
    }
}

//subscribe characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSString *uuid=[service.UUID UUIDString];
    if([uuid isEqualToString:kPowerServiceUUID])
    {
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            NSString *uuid=[characteristic.UUID UUIDString];
            
            if([uuid isEqualToString:kPowerCharacteristicUUID])
            {
                powerCharacteristic=characteristic;
                if ([self.peripheralDelegate respondsToSelector:@selector(powerCharacteristicFound)])
                {
                    [self.peripheralDelegate powerCharacteristicFound];
                }
            }
            else if([uuid isEqualToString:kPasswordCharacteristicUUID])
            {
                passwordCharacteristic=characteristic;
            }
        }
    }
    else
    {
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            NSString *uuid=[characteristic.UUID UUIDString];
            if([uuid isEqualToString:kSpeedCharacteristicUUID] || [uuid isEqualToString:kBatteryCharacteristicUUID] || [uuid isEqualToString:kCameraCharacteristicUUID] ||[uuid isEqualToString:kModeCharateristicUUID])
            {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Can't subscribe characteristic %@. /n", [characteristic.UUID UUIDString]);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!error)
    {
        NSString *uuid=[characteristic.UUID UUIDString];
        if([uuid isEqualToString:kSpeedCharacteristicUUID])
        {
            if ([self.peripheralDelegate respondsToSelector:@selector(speedValueUpdated:)]) {
                [self.peripheralDelegate speedValueUpdated:characteristic.value];
            }
        }
        else if([uuid isEqualToString:kBatteryCharacteristicUUID])
        {
            if ([self.peripheralDelegate respondsToSelector:@selector(batteryValueUpdated:)]) {
                [self.peripheralDelegate batteryValueUpdated:characteristic.value];
            }
        }
        else if([uuid isEqualToString:kCameraCharacteristicUUID])
        {
            NSString *hexString=[spgMScooterUtilities castDataToHexString:characteristic.value];
            
            //photo
            SBSCameraCommand cmdType=SBSCameraCommandNotValid;
            if([hexString isEqualToString:@"11AA"])
            {
                cmdType=SBSCameraCommandTakePhoto;
            }
            else if([hexString isEqualToString:@"22BB"])
            {
                cmdType=SBSCameraCommandStartRecordVideo;
            }
            else if([hexString isEqualToString:@"33CC"])
            {
                cmdType=SBSCameraCommandStopRecordVideo;
            }
            
            if(cmdType!=SBSCameraCommandNotValid)
            {
                if ([self.peripheralDelegate respondsToSelector:@selector(cameraTriggered:)]) {
                    [self.peripheralDelegate cameraTriggered:cmdType];
                }
            }
        }
        else if([uuid isEqualToString:kModeCharateristicUUID])
        {
            NSString *hexString=[spgMScooterUtilities castDataToHexString:characteristic.value];
            
            BOOL modeValue=[hexString isEqualToString:@"CCBB"];//false when "55AA"
            //true
            if(modeValue)
            {
                if ([self.peripheralDelegate respondsToSelector:@selector(modeChanged)]) {
                    [self.peripheralDelegate modeChanged];
                }
            }
        }
        else if([uuid isEqualToString:kPasswordCharacteristicUUID])
        {
            NSString *hexString=[spgMScooterUtilities castDataToHexString:characteristic.value];
            BOOL correct=[hexString isEqualToString:kPasswordCorrectResponse];
            if ([self.peripheralDelegate respondsToSelector:@selector(passwordCertificationReturned:result:)]) {
                [self.peripheralDelegate passwordCertificationReturned:peripheral result:correct];
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!error)
    {
        NSString *uuid=[characteristic.UUID UUIDString];
        if([uuid isEqualToString:kPasswordCharacteristicUUID])
        {
            [self.peripheral readValueForCharacteristic:characteristic];
        }
    }
}
@end
