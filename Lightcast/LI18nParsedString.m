//
//  LI18nParsedString.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LI18nParsedString.h"

@implementation LI18nParsedString

@synthesize
comment,
key,
value;

#pragma mark - Initialization / Finalization

- (void)dealloc
{
    key = nil;
    value = nil;
    comment = nil;
}

#pragma mark - Helpers

- (NSString*)description
{
    NSString *description = [NSString stringWithFormat:@"%@=%@", key, value];
    return description;
}

@end
