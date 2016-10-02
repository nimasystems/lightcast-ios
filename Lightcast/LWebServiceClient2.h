//
//  LWebServiceClient2.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LWebServices.h>
#import <Lightcast/LUrlDownloader.h>

typedef enum
{
    LWebServiceClientRequestTypeGet,
    LWebServiceClientRequestTypePost
} LWebServiceClientRequestType;

@interface LWebServiceClient2 : NSObject

@property (nonatomic, strong, readonly) NSString *hostname;
@property (nonatomic, assign) BOOL shouldUseSSL;
@property (nonatomic, assign) LWebServiceClientRequestType requesType;
@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, strong, readonly) LUrlDownloader *urlDownloader;

@property (nonatomic, copy) NSDate *lastModifiedCheckDate;

@property (nonatomic, assign) NSInteger expectedAPILevel;
@property (nonatomic, assign) NSInteger clientAPILevel;
@property (nonatomic, assign) BOOL shouldMakeAPILevelCheck;

@property (nonatomic, copy) NSString *requestLocale;
@property (nonatomic, copy) NSDictionary *requestHeaders;
@property (nonatomic, copy) NSDictionary *requestCookies;

@property (nonatomic, strong, readonly) NSString *requestUri;

@property (nonatomic, copy) NSString *userAgent;

@property (nonatomic, strong, readonly) NSDate *requestStartTime;
@property (nonatomic, strong, readonly) NSDate *requestEndTime;

@property (nonatomic, strong) NSArray *requestPostFiles;

@property (nonatomic, readonly) NSInteger responseCode;
@property (nonatomic, readonly) NSInteger responseLength;
@property (nonatomic, strong, readonly) NSString *responseMimetype;

@property (nonatomic, assign) BOOL httpAuthEnabled;
@property (nonatomic, copy) NSString *httpAuthUsername;
@property (nonatomic, copy) NSString *httpAuthPassword;

@property (nonatomic, assign) BOOL shouldVerifySSLCerfiticate;

- (id)initWithHostname:(NSString*)aHostname shouldUseSSL:(BOOL)useSSL requestType:(LWebServiceClientRequestType)requestType;
- (id)initWithHostname:(NSString*)aHostname shouldUseSSL:(BOOL)useSSL;

- (BOOL)makeRequest:(NSString*)serviceUrl params:(NSDictionary*)params response:(id*)response error:(NSError**)error;

@end
