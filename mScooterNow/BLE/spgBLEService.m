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
//#define kMyPeripheralIDKey @"myPeripheralID";
static NSString *kMyPeripheralIDKey=@"myPeripheralID";

@implementation spgBLEService
{
    NSArray *interestedServices;
    CBCharacteristic *powerCharacteristic;
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
    }
    return self;
}

#pragma mark - Bluetooth manipulation

-(void)startScan
{
    //find known peripheral
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *idString= [userDefaults stringForKey:kMyPeripheralIDKey];
    if(idString)
    {
        NSUUID *knownId=[[NSUUID alloc] initWithUUIDString:idString];
        NSArray *savedIdentifier=[NSArray arrayWithObjects:knownId, nil];
        NSArray *knownPeripherals= [self.centralManager retrievePeripheralsWithIdentifiers:savedIdentifier];
        if(knownPeripherals.count>0)
        {
            if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)])
            {
                [self.discoverPeripheralsDelegate centralManager:self.centralManager didDiscoverPeripheral:[knownPeripherals firstObject] advertisementData:nil RSSI:nil];
            }
            //clean the saved ID temporarily for demo
            [userDefaults setObject:nil forKey:kMyPeripheralIDKey];
        }
        else//scan
        {
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        }
    }
    else//scan
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
        //save to user defaults
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[peripheral.identifier UUIDString] forKey:kMyPeripheralIDKey];
        [userDefaults synchronize];
        
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
    
    if([self.peripheralDelegate respondsToSelector:@selector(centralManager:connectPeripheral:)])
    {
        [self.peripheralDelegate centralManager:central connectPeripheral:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if([self.peripheralDelegate respondsToSelector:@selector(centralManager:disconnectPeripheral:error:)])
    {
        [self.peripheralDelegate centralManager:central disconnectPeripheral:peripheral error:error];
    }
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
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
            
            if(![mutableString isEqualToString:@"55AA"])
            {
              if ([self.peripheralDelegate respondsToSelector:@selector(cameraTriggered)]) {
                [self.peripheralDelegate cameraTriggered];
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
            
            if(![mutableString isEqualToString:@"55AA"])
            {
            if ([self.peripheralDelegate respondsToSelector:@selector(modeChanged)]) {
                [self.peripheralDelegate modeChanged];
                }
            }
        }
    }
}
@end
