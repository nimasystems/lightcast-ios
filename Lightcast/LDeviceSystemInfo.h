//
//  LDeviceSystemInfo.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat const kLDeviceSystemInfoDefaultNavBarHeight;
extern CGFloat const kLDeviceSystemInfoDefaultTabBarHeight;

@interface LDeviceSystemInfo : NSObject

@property (strong, readonly, getter = getPrimaryMacAddress) NSString *primaryMacAddress;
@property (strong, readonly, getter = getDeviceName) NSString *deviceName;
@property (strong, readonly, getter = getDeviceDescription) NSString *deviceDescription;

@property (strong, readonly, getter = getCurrentResolution) NSString *currentResolution;

@property (strong, readonly, getter = getModel) NSString *model;                    // e.g. @"iPhone", @"iPod Touch"
@property (strong, readonly, getter = getLocalizedModel) NSString *localizedModel;  // localized version of model
@property (strong, readonly, getter = getSystemName) NSString *systemName;          // e.g. @"iPhone OS"
@property (strong, readonly, getter = getSystemVersion) NSString *systemVersion;    // e.g. @"2.0"

#ifdef TARGET_IOS
@property (readonly, getter = getScreenBounds) CGRect screenBounds;
@property (readonly, getter = getApplicationFrame) CGRect applicationFrame;
@property (readonly, getter = getStatusBarHeight) NSInteger statusBarHeight;
@property (readonly, getter = getNavBarFrame) CGRect navBarFrame;

@property (readonly, getter = getOrientation) UIDeviceOrientation orientation;

@property (strong, readonly, getter = getUUID) NSString *UUID;
#endif

#ifdef TARGET_OSX
- (NSString*)cpuName;
#endif

@end
