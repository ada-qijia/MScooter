//
//  spgMScooterDefinitions.h
//  mScooterNow
//
//  Created by v-qijia on 9/19/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#ifndef mScooterNow_spgMScooterDefinitions_h
#define mScooterNow_spgMScooterDefinitions_h

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define kScooterStationPrefix @"BIC "
#define kScooterDeviceName @"NeeZzA"

#define kSpeedServiceUUID @"FFF0"
#define kSpeedCharacteristicUUID @"FFF1"
#define kBatteryServiceUUID @"180F"
#define kBatteryCharacteristicUUID @"2A19"
#define kCameraServiceUUID @"FFD0"
#define kCameraCharacteristicUUID @"FFD1"
#define kMileageServiceUUID @"FFC0"
#define kMileageCharacteristicUUID @"FFC1"

#define kDashboardServiceUUID @"F000BB00-0451-4000-B000-000000000000"
#define kPowerCharacteristicUUID @"F000BB04-0451-4000-B000-000000000000" //on/off
#define kPasswordCharacteristicUUID @"F000BB05-0451-4000-B000-000000000000"
//new added
#define kIdentifyCharacteristicUUID @"F000BB01-0451-4000-B000-000000000000"//upload phone UUID
#define kPowerACKCharacteristicUUID @"F000BB03-0451-4000-B000-000000000000"
//for password & identify
#define kACKResponseCharacteristicUUID @"F000BB02-0451-4000-B000-000000000000"

#define ThemeColor [UIColor colorWithRed:76/255.0 green:193/255.0 blue:209/255.0 alpha:1.0]
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define BackgroundImageColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]];

static NSString * const kAutoReconnectUUIDKey=@"autoReconnectUUID";
static NSString * const kNotFirstUseKey=@"notFirstUse";
static NSString * const kMyPeripheralIDKey= @"myPeripheralID";
static NSString * const kScooterNameKey=@"scooterName";
//default campus mode
static NSString * const kMyScenarioModeKey=@"myScenarioMode";
//nsnumber with power state
static NSString * const kLastPowerStateKey=@"lastPowerState";
static NSString * const kLastLocationKey=@"lastLocation";

static NSString * const kUserKey=@"user";

#define kScenarioModeCampus @"campus"
#define kScenarioModePersonal @"personal"

#define kBeijingCityID @"101010100"

#define kCorrectPin @"0033"
#define kACKCorrectResponse @"01"
#define kACKWrongResponse @"02"
#define kACKTypePhoneID @"01"
#define kACKTypePassword @"02"
#define kACKTypePower @"03"
#define kACKBatteryState @"04"
#define kACKIdentifyContinueResponse @"03"
#define kIdentifySuccessResponse @"00000001"

//ble advertisement data
#define kCBAdvDataLocalName @"kCBAdvDataLocalName"
#define kCBAdvDataServiceData @"kCBAdvDataServiceData"
#define kCBAdvDataServiceUUIDs @"kCBAdvDataServiceUUIDs"

typedef enum:NSUInteger
{
    Gauge,
    ARModeCool,
    ARModeList,
    ARModeMap,
    ARModeNormal
}DashboardMode;

typedef enum:NSInteger
{
    BLEDeviceStateUndefined,
    BLEDeviceStateActive,
    BLEDeviceStateVague,
    BLEDeviceStateInactive
}BLEDeviceState;

typedef enum:NSUInteger
{
    PowerStatUnDefined=0,
    PowerOn=1,
    PowerOff=2,
    PowerAlwaysOn=3,
}PowerState;

typedef enum:NSUInteger
{
    BatteryStateOff=0,
    BatteryStateOn=1,
    BatteryStateUnDefined=2,
}BatteryState;

typedef enum:Byte
{
    PowerOnCmd=247,
    PowerOffCmd=249,
    PowerAlwaysOnCmd=245,
    PowerWithPhoneCmd=243,
}PowerCommand;

#endif
