//
//  LDataSubmitterPlugin.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.06.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LDataSubmitterPlugin.h"

@implementation LDataSubmitterPlugin

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (BOOL)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error
{
    if ([super initialize:aConfiguration notificationDispatcher:aDispatcher error:error])
    {
        if (aConfiguration)
        {
            configuration = aConfiguration;
        }
        
        LogInfo(@"DataSubmitter plugin started");
    }
    
    return YES;
}

#pragma mark -
#pragma mark LPlugin Protocl

- (NSString *)version
{
    return @"1.0.0.0";
}

- (LConfiguration*)defaultConfiguration
{
    return nil;
}

- (BOOL)checkPluginRequirements:(NSString**)minLightcastVer
                maxLightcastVer:(NSString**)maxLightcastVer
             pluginRequirements:(NSArray**)pluginRequirements
{
    return NO;
}

- (id<LDatabaseSchemaProtocol>)databaseSchemaInstance
{
    return nil;
}

@end
