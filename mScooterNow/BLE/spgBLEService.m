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
    //key:UUID NSString, value: CBCharacteristic*
    NSMutableDictionary *upstreamCharacteristics;
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
    CBUUID *cameraServiceUUID=CBUUID(kCameraServiceUUID);
    interestedServices=@[cameraServiceUUID];
    
    upstreamCharacteristics=[NSMutableDictionary dictionary];
    return self;
}

#pragma mark - Bluetooth manipulation

-(void)startScan
{
    [spgMScooterUtilities savePreferenceWithKey:kAutoReconnectUUIDKey value:nil];
    //[self.centralManager scanForPeripheralsWithServices:interestedServices options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    [self.centralManager scanForPeripheralsWithServices:interestedServices options:nil];
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

//manually disconnect
-(void)disConnectPeripheral
{
    if(self.centralManager!=nil && self.peripheral!=nil)
    {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
    
    [spgMScooterUtilities savePreferenceWithKey:kAutoReconnectUUIDKey value:nil];
}

-(void)writePower:(NSData *) data
{
    CBCharacteristic *powerCharacteristic=[upstreamCharacteristics objectForKey:kPowerCharacteristicUUID];
    
    if (self.peripheral && powerCharacteristic) {
        [self.peripheral writeValue:data forCharacteristic:powerCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

-(BOOL)writePassword:(NSData *) data
{
    CBCharacteristic *passwordCharacteristic=[upstreamCharacteristics objectForKey:kPasswordCharacteristicUUID];
    if (self.peripheral && passwordCharacteristic) {
        [self.peripheral writeValue:data forCharacteristic:passwordCharacteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)IdentifyPhone:(NSData *)data
{
    CBCharacteristic *identifyCharacteristic=[upstreamCharacteristics objectForKey:kIdentifyCharacteristicUUID];
    if (self.peripheral && identifyCharacteristic) {
        [self.peripheral writeValue:data forCharacteristic:identifyCharacteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)clean
{
    [upstreamCharacteristics removeAllObjects];
    
    if(self.peripheral && self.peripheral.state==CBPeripheralStateConnected)
    {
        [self disConnectPeripheral];
    }
    self.peripheral=nil;
    
    self.centralManager=nil;
    self.discoverPeripheralsDelegate=nil;
    self.peripheralDelegate=nil;
    
    self.isCertified=nil;
}

#pragma mark - central manager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManagerDidUpdateState:)])
    {
        [self.discoverPeripheralsDelegate centralManagerDidUpdateState:self.centralManager];
    }
    
    if([self.peripheralDelegate respondsToSelector:@selector(centralManagerDidUpdateState:)])
    {
        [self.peripheralDelegate centralManagerDidUpdateState:self.centralManager];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@",advertisementData);
    
    NSRange range= [peripheral.name rangeOfString:kScooterDeviceName options:NSCaseInsensitiveSearch];
    if(range.location!=NSNotFound)
    {
        self.peripheral=peripheral;
        if([self.discoverPeripheralsDelegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)])
        {
            [self.discoverPeripheralsDelegate centralManager:self.centralManager didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
        }
        
        if([self.peripheralDelegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)])
        {
            [self.peripheralDelegate centralManager:self.centralManager didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
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
    self.peripheral=nil;
    self.isCertified=nil;
    
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
    self.peripheral=nil;
    self.isCertified=nil;
    
    [upstreamCharacteristics removeAllObjects];
    
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
        else if([uuid isEqualToString:kDashboardServiceUUID])
        {
            //discover password
            CBUUID *passwordUUID=CBUUID(kPasswordCharacteristicUUID);
            CBUUID *powerUUID=CBUUID(kPowerCharacteristicUUID);
            CBUUID *identifyUUID=CBUUID(kIdentifyCharacteristicUUID);
            CBUUID *ackResponseUUID=CBUUID(kACKResponseCharacteristicUUID);
            CBUUID *powerACKUUID=CBUUID(kPowerACKCharacteristicUUID);
            
            [peripheral  discoverCharacteristics:@[passwordUUID,powerUUID,identifyUUID,ackResponseUUID,powerACKUUID] forService:service];
        }
        else if([uuid isEqualToString:kMileageServiceUUID])
        {
            characteristicUUID=CBUUID(kMileageCharacteristicUUID);
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
    if([uuid isEqualToString:kDashboardServiceUUID])
    {
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            NSString *uuid=[characteristic.UUID UUIDString];
            //write
            [upstreamCharacteristics setObject:characteristic forKey:uuid];
        }
    }
    else
    {
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            NSString *uuid=[characteristic.UUID UUIDString];
            if([uuid isEqualToString:kSpeedCharacteristicUUID] || [uuid isEqualToString:kBatteryCharacteristicUUID] || [uuid isEqualToString:kCameraCharacteristicUUID] ||[uuid isEqualToString:kMileageCharacteristicUUID])
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
        else if([uuid isEqualToString:kMileageCharacteristicUUID])
        {
            if ([self.peripheralDelegate respondsToSelector:@selector(mileageUpdated:)]) {
                [self.peripheralDelegate mileageUpdated:characteristic.value];
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
        /*
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
         }*/
#pragma - ack
        /*
         else if([uuid isEqualToString:kPasswordCharacteristicUUID])
         {
         NSString *hexString=[spgMScooterUtilities castDataToHexString:characteristic.value];
         BOOL correct=[hexString isEqualToString:kPasswordCorrectResponse];
         if ([self.peripheralDelegate respondsToSelector:@selector(passwordCertificationReturned:result:)]) {
         [self.peripheralDelegate passwordCertificationReturned:peripheral result:correct];
         }
         
         //save whether auto reconnect next time.
         NSString * boolString = correct ? [peripheral.identifier UUIDString] : nil;
         [spgMScooterUtilities savePreferenceWithKey:kAutoReconnectUUIDKey value:boolString];
         }*/
        else if([uuid isEqualToString:kPowerACKCharacteristicUUID])
        {
            if ([self.peripheralDelegate respondsToSelector:@selector(powerStateReturned:result:)])
            {
                [self.peripheralDelegate powerStateReturned:peripheral result:characteristic.value];
            }
        }
        else if([uuid isEqualToString:kACKResponseCharacteristicUUID])
        {
            NSString *hexString=[spgMScooterUtilities castDataToHexString:characteristic.value];
            
            NSString *type=[hexString substringToIndex:2];
            
            if([type isEqualToString:kACKTypePassword])
            {
                BOOL success=[[hexString substringFromIndex:2] isEqualToString:kACKCorrectResponse];
                self.isCertified=[NSNumber numberWithBool:success];
                
                if ([self.peripheralDelegate respondsToSelector:@selector(passwordCertificationReturned:result:)]) {
                    [self.peripheralDelegate passwordCertificationReturned:peripheral result:success];
                }
                
                //save whether auto reconnect next time.
                NSString * boolString = success ? [peripheral.identifier UUIDString] : nil;
                [spgMScooterUtilities savePreferenceWithKey:kAutoReconnectUUIDKey value:boolString];
            }
            else if([type isEqualToString:kACKTypePhoneID])
            {
                NSString *result= [hexString substringFromIndex:2];
                if([result isEqualToString:kACKCorrectResponse]||[result isEqualToString:kACKWrongResponse])
                {
                    BOOL success=[result isEqualToString:kACKCorrectResponse];
                    self.isCertified=[NSNumber numberWithBool:success];
                }
                
                if ([self.peripheralDelegate respondsToSelector:@selector(identifyReturned:result:)])
                {
                    [self.peripheralDelegate identifyReturned:peripheral result:result];
                }
            }
            /*else if([type isEqualToString:kACKBatteryState])
            {
                if ([self.peripheralDelegate respondsToSelector:@selector(batteryStateReturned:)])
                {
                    [self.peripheralDelegate batteryStateReturned:success];
                }
            }*/
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!error)
    {
        NSString *uuid=[characteristic.UUID UUIDString];
        
        if([uuid isEqualToString:kPowerCharacteristicUUID])
        {
            CBCharacteristic *powerAckCharacteristic=[upstreamCharacteristics objectForKey:kPowerACKCharacteristicUUID];
            [self.peripheral readValueForCharacteristic:powerAckCharacteristic];
        }
        else if([uuid isEqualToString:kIdentifyCharacteristicUUID])
        {
            CBCharacteristic *ackCharacteristic=[upstreamCharacteristics objectForKey:kACKResponseCharacteristicUUID];
            [self.peripheral readValueForCharacteristic:ackCharacteristic];
            
            CBCharacteristic *powerCharacteristic=[upstreamCharacteristics objectForKey:kPowerACKCharacteristicUUID];
            [self.peripheral readValueForCharacteristic:powerCharacteristic];
        }
        else if([uuid isEqualToString:kPasswordCharacteristicUUID])
        {
            CBCharacteristic *ackCharacteristic=[upstreamCharacteristics objectForKey:kACKResponseCharacteristicUUID];
            [self.peripheral readValueForCharacteristic:ackCharacteristic];
        }
    }
}
@end
