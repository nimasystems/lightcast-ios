//
//  LWebServicesValidationError.m
//  cocoa
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Stampii S.L. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LWebServicesValidationError.h"

@implementation LWebServicesValidationError

@synthesize
fieldName,
errorMessage;

#pragma mark -
#pragma mark Initialization / Finalization

- (void)dealloc
{
    fieldName = nil;
    errorMessage = nil;
}

#pragma mark -
#pragma mark Helpers

- (NSString*)description
{
    NSString *d = [NSString stringWithFormat:@"Field=%@ Error=%@",
                   fieldName,
                   errorMessage
                   ];
    return d;
}

@end
