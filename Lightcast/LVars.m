//
//  LVars.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 17.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LVars.h"

@implementation LVars

+ (BOOL)isNullOrEmpty:(id)var
{
    BOOL isValid = (var && ![var isEqual:[NSNull null]]);
    return !isValid;
}

+ (id)nilify:(id)var
{
    id ret = [LVars isNullOrEmpty:var] ? nil : var;
    return ret;
}

@end
