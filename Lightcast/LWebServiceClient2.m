//
//  LWebServiceClient2.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LWebServiceClient2.h"
#import "LWebServicesDefines.h"
#import "LWebServiceError.h"
#import "LWebServicesValidationError.h"
#import "LWebServicesDefines.h"

@interface LWebServiceClient2(Private)

- (NSString*)formattedUrl:(NSString*)aHostname shouldUseSSL:(BOOL)useSSL serviceUrl:(NSString*)serviceUrl params:(NSDictionary*)params requestUri:(NSString**)requestUri_;
- (void)markTime:(BOOL)started;
- (BOOL)makeDataRequest:(NSString*)uri response:(id*)response error:(NSError**)error;
- (NSString *)urlEncodeValue:(NSString *)str;

@end

@implementation LWebServiceClient2 {
    
    NSString *_serviceUrl;
    NSDictionary *_params;
}

@synthesize
hostname,
shouldUseSSL,
shouldVerifySSLCerfiticate,
expectedAPILevel,
clientAPILevel,
requesType,
urlDownloader,
timeout,
lastModifiedCheckDate,
shouldMakeAPILevelCheck,
requestLocale,
requestHeaders,
requestCookies,
userAgent,
requestUri,
requestStartTime,
requestEndTime,
responseCode,
responseLength,
requestPostFiles,
responseMimetype,
httpAuthEnabled,
httpAuthUsername,
httpAuthPassword;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)initWithHostname:(NSString*)aHostname shouldUseSSL:(BOOL)useSSL requestType:(LWebServiceClientRequestType)requestType;
{
    self = [super init];
    if (self)
    {
        lassert(![NSString isNullOrEmpty:aHostname]);
        
        hostname = aHostname;
        shouldUseSSL = useSSL;
        requesType = requestType;
        urlDownloader = nil;
        
        shouldVerifySSLCerfiticate = YES;
        
        requestUri = nil;
        _serviceUrl = nil;
        _params = nil;
        
        // set the default timeout
        timeout = LWebServiceDefaultTimeout;
        
        shouldMakeAPILevelCheck = YES;
        
        expectedAPILevel = LWebServiceDefaultAPILevel;
    }
    return self;
}

- (id)initWithHostname:(NSString*)aHostname shouldUseSSL:(BOOL)useSSL
{
    return [self initWithHostname:aHostname shouldUseSSL:useSSL requestType:LWebServiceClientRequestTypeGet];
}

- (id)init
{
    return [self initWithHostname:nil shouldUseSSL:NO];
}

- (void)dealloc
{
    hostname = nil;
    lastModifiedCheckDate = nil;
    requestLocale = nil;
    requestHeaders = nil;
    requestCookies = nil;
    userAgent = nil;
    requestStartTime = nil;
    requestEndTime = nil;
    responseMimetype = nil;
    requestPostFiles = nil;
    httpAuthUsername = nil;
    httpAuthPassword = nil;
    
    requestUri = nil;
    _serviceUrl = nil;
    _params = nil;
    
    urlDownloader = nil;
}

#pragma mark -
#pragma mark Service Calls

- (BOOL)makeRequest:(NSString*)serviceUrl params:(NSDictionary*)params response:(id*)response error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (response != NULL)
    {
        *response = nil;
    }
    
    // save internally
    if (_serviceUrl != serviceUrl)
    {
        _serviceUrl = serviceUrl;
    }
    
    if (_params != params)
    {
        _params = params;
    }
    
    // make the uri - if POST - no params are to be passed
    // as they will be passed in the POST request itself
    NSString *requestUri_ = nil;
    BOOL isPost = (requesType == LWebServiceClientRequestTypePost);
    NSDictionary *paramsForUrl = isPost ? nil : params;
    
    NSString *uri = [self formattedUrl:hostname shouldUseSSL:shouldUseSSL serviceUrl:serviceUrl params:paramsForUrl requestUri:&requestUri_];
    
    lassert(![NSString isNullOrEmpty:uri]);
    lassert(![NSString isNullOrEmpty:requestUri_]);
    
    if (requestUri_ != requestUri)
    {
        requestUri = requestUri_;
    }
    
    // mark the start
    [self markTime:YES];
    
    @try
    {
        BOOL res = [self makeDataRequest:uri response:response error:error];
        
        if (!res)
        {
            return NO;
        }
    }
    @finally
    {
        // mark the end
        [self markTime:NO];
    }
    
    return YES;
}

- (NSMutableDictionary*)preparedRequestHeaders {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    if (self.requestHeaders) {
        [headers addEntriesFromDictionary:self.requestHeaders];
    }
    
    // add the client api level header
    if (self.clientAPILevel) {
        [headers setObject:[NSString stringWithFormat:@"%d", (int)self.clientAPILevel] forKey:XLC_CLIENT_APILEVEL_HEADER_NAME];
    }
    
    return headers;
}

- (BOOL)makeDataRequest:(NSString*)uri response:(id*)response error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (response != NULL)
    {
        *response = nil;
    }
    
    lassert(uri);
    
    NSURL *url_ = [NSURL URLWithString:uri];
    
    lassert(url_ != nil);
    
    urlDownloader = nil;
    
    // set method
    BOOL isPost = (requesType == LWebServiceClientRequestTypePost);
    LUrlDownloadRequestMethod requestMethod = (isPost ? LUrlDownloadRequestMethodPost : LUrlDownloadRequestMethodGet);
    
    urlDownloader = [[LUrlDownloader alloc] initWithUrl:url_ downloadTo:nil requestMethod:requestMethod timeout:timeout];
    
    lassert(urlDownloader);
    
    // ssl verification
    urlDownloader.shouldVerifySSLCerfiticate = self.shouldVerifySSLCerfiticate;
    
    // set locale
    urlDownloader.requestLocale = self.requestLocale;
    
    // pass files
    urlDownloader.postFiles = self.requestPostFiles;
    
    // set user agent
    if (userAgent)
    {
        urlDownloader.userAgent = userAgent;
    }
    
    // set cookies
    urlDownloader.cookies = requestCookies;
    
    // set custom headers
    urlDownloader.requestHeaders = [self preparedRequestHeaders];
    
    // If-Modified-Since check
    urlDownloader.requestIfModifiedSince = self.lastModifiedCheckDate;
    
    // set HTTP Auth
    urlDownloader.httpAuthEnabled = self.httpAuthEnabled;
    urlDownloader.httpAuthUsername = self.httpAuthUsername;
    urlDownloader.httpAuthPassword = self.httpAuthPassword;
    
    // post params
    if (isPost)
    {
        urlDownloader.postParams = _params;
    }
    
    LogDebug(@"HTTP Request: %@", urlDownloader.url);
    //LogDebug(@"Making http request (%@) with headers:\n\n%@ and params:\n\n%@", _urlRequest.URL, _urlRequest.allHTTPHeaderFields, _params);
    
    // make the request
    NSError *requestError = nil;
    BOOL ret = [urlDownloader startDownload:&requestError];
    
    if (!ret)
    {
        if (error != NULL)
        {
            *error = requestError;
        }
        
        return NO;
    }
    
    urlDownloader.downloadDelegate = nil;
    
    // parse the response
    NSData *receivedData = urlDownloader.receivedData;
    
    lassert(receivedData);
    
    NSDictionary *responseHeaders = urlDownloader.responseHeaders;
    
    //LogDebug(@"Response headers: %@", responseHeaders);
    
    responseCode = urlDownloader.responseCode;
    responseLength = urlDownloader.responseLength;
    
    //LogDebug(@"HTTP Request END: %@, ResponseCode: %d, ResponseLength: %d, Response Headers:\n\n%@\n\n", _urlRequest.URL, responseCode, responseLength, responseHeaders);
    
    if (responseMimetype != urlDownloader.responseContentType)
    {
        responseMimetype = urlDownloader.responseContentType;
    }
    
    if (responseLength < 1)
    {
        responseLength = receivedData ? [receivedData length] : 0;
    }
    
    //LogDebug(@"Response code: %d (%@)", responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
    
    if (responseCode != 200 && responseCode != 304)
    {
        LogError(@"Got HTTP Error (%d), Contents received:\n\n:%s", (int)responseCode, [receivedData bytes]);
        
        // make this an error
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"HTTP error (Response code: %d)"), responseCode];
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_INVALID_SERVER_RESPONSE userInfo:errorDetail];
        }
        
        return NO;
    }
    
    // check the returned API level
    if (shouldMakeAPILevelCheck)
    {
        if (responseHeaders && [responseHeaders count])
        {
            NSString *serverApiLevel = [responseHeaders objectForKey:XLC_APILEVEL_HEADER_NAME];
            
            if (![NSString isNullOrEmpty:serverApiLevel])
            {
                NSInteger serverApiLevelInt = [serverApiLevel intValue];
                
                if (serverApiLevelInt > expectedAPILevel)
                {
                    if (error != NULL)
                    {
                        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                        NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"Unsupported Server API Level (supported: %d, server returned: %d)"), expectedAPILevel, serverApiLevelInt];
                        [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                        *error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_API_UNSUPPORTED userInfo:errorDetail];
                    }
                    
                    return NO;
                }
            }
        }
    }
    
    // check if we have a 304 - Not Modified
    if (responseCode == 304)
    {
        lassert(false);
        
        // do nothing else
        return YES;
    }
    
    // check if there is any data to parse
    // if there isn't any - that is NOT an error!
    if (!receivedData || [receivedData length] < 1)
    {
        return YES;
    }
    
    // parse the expected JSON response now
    id parserResult = nil;
    
    NSError *jsonParsingError = nil;
    
    @try
    {
        NSError *err = nil;
        parserResult = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&err];
        
        if (err)
        {
            // check if the result is string FALSE - which means no results
            NSString *tmp = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            
            if (![tmp isEqualToString:@"false"])
            {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:[NSString stringWithFormat:LightcastLocalizedString(@"JSON Parsing Error: %@"), err] forKey:NSLocalizedDescriptionKey];
                jsonParsingError = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
                
                lassert(false);
                
                if (error != NULL)
                {
                    *error = jsonParsingError;
                }
                
                return NO;
            }
        }
    }
    @catch (NSException *e)
    {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:[NSString stringWithFormat:LightcastLocalizedString(@"JSON Parsing Error: %@"), [e reason]] forKey:NSLocalizedDescriptionKey];
        jsonParsingError = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
        
        lassert(false);
        
        if (error != NULL)
        {
            *error = jsonParsingError;
        }
        
        return NO;
    }
    
    if (!parserResult)
    {
        // no data decoded - not an error
        return YES;
    }
    
    // assign the response
    if (response != NULL)
    {
        *response = [parserResult copy];
    }
    
    NSDictionary *err = ([parserResult isKindOfClass:[NSDictionary class]] && [parserResult objectForKey:@"error"]) ? [parserResult objectForKey:@"error"] : nil;
    
    if (!err)
    {
        return YES;
    }
    
    // yes - we have an error - try to parse it
    if ([err isKindOfClass:[NSDictionary class]])
    {
        NSString *srvErrDomain = [err objectForKey:@"domain"];
        NSString *srvErrMessage = [err objectForKey:@"message"];
        NSString *srvErrException = [err objectForKey:@"exception"];
        NSString *srvErrTrace = [err objectForKey:@"trace"];
        NSInteger srvErrCode = [err objectForKey:@"code"] ? [[err objectForKey:@"code"] intValue] : 0;
        NSString *srvErrExtraData = [err objectForKey:@"extra_data"];
        
        // parse the validation errors, if any
        NSDictionary *srvValidationErrors = [err objectForKey:@"validation_errors"];
        
        NSMutableArray *allErrors = [[NSMutableArray alloc] init];
        
        if (srvValidationErrors)
        {
            lassert([srvValidationErrors isKindOfClass:[NSDictionary class]]);
            
            if ([srvValidationErrors isKindOfClass:[NSDictionary class]])
            {
                for(NSString *key in srvValidationErrors)
                {
                    NSString *v = [srvValidationErrors objectForKey:key];
                    
                    LWebServicesValidationError *err = [[LWebServicesValidationError alloc] init];
                    err.fieldName = key;
                    err.errorMessage = v;
                    
                    [allErrors addObject:err];
                }
            }
        }
        
        // create the error
        LWebServiceError *ler = [[LWebServiceError alloc] initWithStampiiError:srvErrDomain errorMessage:srvErrMessage errorCode:srvErrCode];
        ler.exceptionName = srvErrException;
        ler.trace = srvErrTrace;
        ler.extraData = srvErrExtraData;
        ler.validationErrors = allErrors;
        
        if (error != NULL)
        {
            *error = ler;
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Helpers

- (void)markTime:(BOOL)started
{
    NSDate *now = [NSDate date];
    
    if (started)
    {
        if (requestStartTime != now)
        {
            requestStartTime = now;
        }
    }
    else
    {
        if (requestEndTime != now)
        {
            requestEndTime = now;
        }
    }
}

- (NSString*)formattedUrl:(NSString*)aHostname shouldUseSSL:(BOOL)useSSL serviceUrl:(NSString*)serviceUrl params:(NSDictionary*)params requestUri:(NSString**)requestUri_
{
    if (requestUri_ != NULL)
    {
        *requestUri_ = nil;
    }
    
    lassert(![NSString isNullOrEmpty:aHostname]);
    lassert(![NSString isNullOrEmpty:serviceUrl]);
    
    NSString *uri = nil;
    
    // parse the params
    NSString *paramsStr = nil;
    
    if (params && [params count])
    {
        NSMutableArray *tmpA = [[NSMutableArray alloc] initWithCapacity:[params count]];
        
        for(NSString *key in params)
        {
            NSString *val = [NSString stringWithFormat:@"%@",[params objectForKey:key]];
            
            if ([NSString isNullOrEmpty:val])
            {
                // skip params with empty value
                continue;
            }
            
            NSString *tmp = [NSString stringWithFormat:@"%@=%@",
                             [self urlEncodeValue:key],
                             [self urlEncodeValue:val]
                             ];
            
            [tmpA addObject:tmp];
        }
        
        if ([tmpA count])
        {
            paramsStr = [NSString stringWithFormat:@"?%@",
                         [tmpA componentsJoinedByString:@"&"]
                         ];
        }
    }
    
    uri = [NSString stringWithFormat:@"%@%@%@%@",
           (useSSL ? @"https://" : @"http://"),
           aHostname,
           serviceUrl,
           (paramsStr ? paramsStr : @"")
           ];
    
    if (requestUri_ != NULL)
    {
        *requestUri_ = [NSString stringWithFormat:@"%@%@",
                        serviceUrl,
                        (paramsStr ? paramsStr : @"")
                        ];
    }
    
    return uri;
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8));
    return result;
}

@end
