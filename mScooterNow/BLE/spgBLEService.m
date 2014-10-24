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
    CBCharacteristic *powerTestCharacteristic;
    CBCharacteristic *powerTest2Characteristic;
    //NSMutableString *modeChangeSignals;
}

- (id)initWithDelegates:(id<spgBLEServiceDiscoverPeripheralsDelegate>)delegate peripheralDelegate:(id<spgBLEServicePeripheralDelegate>) peripheralDelegate
{
    self = [super init];
    if (self) {       
        self.discoverPeripheralsDelegate=delegate;
        self.peripheralDelegate=peripheralDelegate;
        self.centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.centralManager.delegate=self;
        
        //initilize interested service
        CBUUID *speedServiceUUID=CBUUID(kSpeedCharacteristicUUID);
        CBUUID *batteryServiceUUID=CBUUID(kBatteryCharacteristicUUID);
        CBUUID *cameraServiceUUID=CBUUID(kCameraServiceUUID);
        CBUUID *powerServiceUUID=CBUUID(kPowerServiceUUID);
        CBUUID *modeServiceUUID=CBUUID(kModeServiceUUID);
        interestedServices=@[speedServiceUUID,batteryServiceUUID,cameraServiceUUID,modeServiceUUID,powerServiceUUID];
        
        //modeChangeSignals=[[NSMutableString alloc] init];
    }
    return self;
}

#pragma mark - Bluetooth manipulation

-(void)startScan
{
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

-(void)stopScan
{
    [self.centralManager stopScan];
}

-(void)connectPeripheral:(CBPeripheral *)peripheral
{
    if(self.centralManager!=nil && peripheral!=nil)
    {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

-(void)disConnectPeripheral:(CBPeripheral *)peripheral
{
    if(self.centralManager!=nil && peripheral!=nil)
    {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

-(void)writePower:(CBPeripheral *)peripheral value:(NSData *) data
{
    if (peripheral && powerCharacteristic) {
        [peripheral writeValue:data forCharacteristic:powerCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

-(void)writeTestPower:(CBPeripheral *)peripheral value:(NSData *)data
{
    if (peripheral && powerTestCharacteristic && powerTest2Characteristic) {
        [peripheral writeValue:data forCharacteristic:powerTestCharacteristic type:CBCharacteristicWriteWithResponse];
        [peripheral writeValue:data forCharacteristic:powerTest2Characteristic type:CBCharacteristicWriteWithResponse];
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
    if(range.location!=NSNotFound)
    {
/*
        //save to user defaults
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[peripheral.identifier UUIDString] forKey:kMyPeripheralIDKey];
        [userDefaults synchronize];
*/
        
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
            //test
            characteristicUUID=CBUUID(kPowerTestCharacteristicUUID);
            [peripheral  discoverCharacteristics:@[characteristicUUID] forService:service];
            
            characteristicUUID=CBUUID(kPowerTest2CharacteristicUUID);
            [peripheral  discoverCharacteristics:@[characteristicUUID] forService:service];
            
            characteristicUUID=CBUUID(kPowerCharacteristicUUID);
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
            //test
            else if([uuid isEqualToString:kPowerTestCharacteristicUUID])
            {
                powerTestCharacteristic=characteristic;
            }
            else if([uuid isEqualToString:kPowerTest2CharacteristicUUID])
            {
                powerTest2Characteristic=characteristic;
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
            NSMutableString *mutableString=[[NSMutableString alloc] init];
            Byte *bytes=(Byte *)characteristic.value.bytes;
            for(int i=0;i<characteristic.value.length;i++)
            {
                NSString *hex=[NSString stringWithFormat:@"%X", bytes[i]];
                [mutableString appendString:hex];
            }
            
            //photo
            SBSCameraCommand cmdType=SBSCameraCommandNotValid;
            if([mutableString isEqualToString:@"11AA"])
            {
                cmdType=SBSCameraCommandTakePhoto;
            }
            else if([mutableString isEqualToString:@"22BB"])
            {
                cmdType=SBSCameraCommandStartRecordVideo;
            }
            else if([mutableString isEqualToString:@"33CC"])
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
            NSMutableString *mutableString=[[NSMutableString alloc] init];
            Byte *bytes=(Byte *)characteristic.value.bytes;
            for(int i=0;i<characteristic.value.length;i++)
            {
                NSString *hex=[NSString stringWithFormat:@"%X", bytes[i]];
                [mutableString appendString:hex];
            }
            
            BOOL modeValue=[mutableString isEqualToString:@"CCBB"];//false when "55AA"
            //true
            if(modeValue)
            {
            if ([self.peripheralDelegate respondsToSelector:@selector(modeChanged)]) {
                [self.peripheralDelegate modeChanged];
                }
            }
            
            /*
            //if the sequence is "TFFT", scooter has been auto powered off
            NSString *modeSymbol=modeValue?@"T":@"F";
            [modeChangeSignals appendString:modeSymbol];
            if(modeChangeSignals.length>4)
            {
                [modeChangeSignals deleteCharactersInRange:NSMakeRange(0, 1)];
            }
            
            if(modeChangeSignals.length==4&&[modeChangeSignals isEqualToString:@"TFFT"])
            {
                if ([self.peripheralDelegate respondsToSelector:@selector(autoPoweredOff)]) {
                    [self.peripheralDelegate autoPoweredOff];
                }
            }
             */
        }
    }
}
@end
