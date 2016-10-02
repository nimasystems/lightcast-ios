//
//  LWebServiceError.m
//  cocoa
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Stampii S.L. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LWebServiceError.h"

NSString *const APIErrorDomain = @"com.nimasystems.lightcast.APIError";

@implementation LWebServiceError

@synthesize
apiDomainName,
trace,
exceptionName,
extraData,
validationErrors;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)initWithStampiiError:(NSString*)apiDomainName_ errorMessage:(NSString*)errorMessage_ errorCode:(NSInteger)errorCode_
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          (errorMessage_ ? [errorMessage_ copy] : @""), NSLocalizedDescriptionKey
                          , nil];
    self = [super initWithDomain:APIErrorDomain code:errorCode_ userInfo:dict];
    if (self)
    {
        apiDomainName = apiDomainName_;
    }
    return self;
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    return [self initWithStampiiError:nil errorMessage:nil errorCode:0];
}

- (void)dealloc
{
    apiDomainName = nil;
    trace = nil;
    exceptionName = nil;
    extraData = nil;
    validationErrors = nil;
}

#pragma mark -
#pragma mark Helpers

- (NSString*)description
{
    NSString *pd = [super description];
    
    NSString *d = [NSString stringWithFormat:@"%@ ApiDomainName=%@ ExceptionName=%@ Trace=%@ ExtraData=%@ ValidationErrors=%@",
                   pd,
                   apiDomainName,
                   exceptionName,
                   trace,
                   extraData,
                   validationErrors
                   ];
    return d;
}

@end
