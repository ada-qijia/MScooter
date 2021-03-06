//
//  spgMScooterDefinitions.h
//  mScooterNow
//
//  Created by v-qijia on 9/19/14.
//  Copyright (c) 2014 v-qijia. All rights reserved.
//

#ifndef mScooterNow_spgMScooterDefinitions_h
#define mScooterNow_spgMScooterDefinitions_h

#define kScooterStationPrefix @"BIC "
#define kScooterDeviceName @"SCOOTER"

#define kSpeedServiceUUID @"FFF0"
#define kSpeedCharacteristicUUID @"FFF1"
#define kBatteryServiceUUID @"180F"
#define kBatteryCharacteristicUUID @"2A19"
#define kCameraServiceUUID @"FFD0"
#define kCameraCharacteristicUUID @"FFD1"
#define kModeServiceUUID @"FFC0"
#define kModeCharateristicUUID @"FFC1"
#define kPasswordServiceUUID @"F000BB00-0451-4000-B000-000000000000"
#define kPasswordCharacteristicUUID @"F000BB05-0451-4000-B000-000000000000"
//light&power
#define kPowerServiceUUID @"F000BB00-0451-4000-B000-000000000000"
#define kPowerCharacteristicUUID @"F000BB04-0451-4000-B000-000000000000"


#define ThemeColor [UIColor colorWithRed:76/255.0 green:193/255.0 blue:209/255.0 alpha:1.0]
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define BackgroundImageColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]];

static NSString * const kNotFirstUseKey=@"notFirstUse";
static NSString * const kMyPeripheralIDKey= @"myPeripheralID";
//default campus mode
static NSString * const kMyScenarioModeKey=@"myScenarioMode";
//YES,NO
static NSString * const kPasswordOnKey=@"passwordOn";
#define kScenarioModeCampus @"campus"
#define kScenarioModePersonal @"personal"

#define kBeijingCityID @"101010100"

#define kCorrectPin @"0033"
#define kPasswordCorrectResponse @"0001"

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

#endif
