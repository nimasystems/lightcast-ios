//
//  LDataSubmitter.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.06.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LDataSubmitter.h"
#import <Lightcast/LUrlDownloader.h>

NSString *const kLDataSubmitterDefaultGroup = @"generic";
NSString *const kLDatSubmitterErrorDomain = @"com.nimasystems.lightcast.LDataSubmitter";
NSInteger const kLDataSubmitterDefaultSessionKeyLength = 50;

NSString *const kLDataSubmitterSessionKeyPostKey = @"session_key";
NSString *const kLDataSubmitterFilesGroupPostKey = @"file_groups";

@interface LDataSubmitter()

@property (nonatomic, strong) NSString *sessionKey;
@property (nonatomic, assign) LDataSubmitterState state;

@property (nonatomic, strong) NSMutableDictionary *files;
@property (nonatomic, strong) NSMutableDictionary *properties;

@property (nonatomic, strong) dispatch_queue_t sendQueue;

@property (nonatomic, assign) NSInteger activeSessions;
@property (nonatomic, strong) NSObject *activeSessionsLock;

@property (nonatomic, assign) BOOL cancelFlag;

@end

@implementation LDataSubmitter

#pragma mark - Initialization / Finalization

- (id)initWithUrl:(NSURL*)url_
{
    self = [super init];
    if (self)
    {
        self.remoteUrl = [url_ copy];
        
        _files = [[NSMutableDictionary alloc] init];
        _properties = [[NSMutableDictionary alloc] init];
        
        _activeSessionsLock = [[NSObject alloc] init];
        
        // default timeout
        self.connectionTimeout = LUrlDownloaderDefaultTimeout;
        
        _sendQueue = dispatch_queue_create("com.nimasystems.lightcast.LDataSubmitter", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)init
{
    return [self initWithUrl:nil];
}

- (void)dealloc
{
    [self cancel];
    
    self.dataSubmitterDelegate = nil;
    
    if (_sendQueue != NULL)
    {
        dispatch_sync(_sendQueue, ^{});
        _sendQueue = NULL;
    }
    
    _activeSessionsLock = nil;
    
    _files = nil;
    _properties = nil;
    self.sessionKey = nil;
    
    self.remoteUrl = nil;
    self.userAgent = nil;
    self.requestHeaders = nil;
}

#pragma mark - Sending

- (BOOL)startSending:(NSError**)error
{
    NSString *sessionKey_ = [self generateSessionKey];
    lassert(![NSString isNullOrEmpty:sessionKey_]);
    
    return [self startSending:sessionKey_ error:error];
}

- (BOOL)startSending:(NSString*)sessionKey_ error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:sessionKey_])
    {
        lassert(false);
        return NO;
    }
    
    if (self.state == LDataSubmitterStateWorking)
    {
        return NO;
    }
    
    if (!self.remoteUrl)
    {
        return NO;
    }
    
    // start sending
    
    // set the state to working
    self.state = LDataSubmitterStateWorking;
    _cancelFlag = NO;
    
    @synchronized(_activeSessionsLock)
    {
        _activeSessions = 0;
    }
    
    // assign the key
    if (sessionKey_ != self.sessionKey)
    {
        self.sessionKey = [sessionKey_ copy];
    }
    
    // inform the delegate
    if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didBeginSending:)])
    {
        [self.dataSubmitterDelegate didBeginSending:self];
    }
    
    // pool all requests
    
    // take a snapshot of the params to send so nothing else
    // changes them meanwhile
    NSURL *url_ = [self.remoteUrl copy];
    NSDictionary *files_ = [self.files copy];
    NSDictionary *props_ = [self.properties copy];
    NSString *sessionKey__ = [self.sessionKey copy];
    
    // pool props
    if (props_ && [props_ count])
    {
        @synchronized(_activeSessionsLock)
        {
            _activeSessions++;
        }
        
        dispatch_async(_sendQueue, ^{
            
            // check if cancelled
            if (self.cancelFlag)
            {
                return;
            }
            
            // inform the delegate
            if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(willBeginSendingProperties:properties:)])
            {
                [self.dataSubmitterDelegate willBeginSendingProperties:self properties:props_];
            }
            
            @try
            {
                NSError *err = nil;
                BOOL ret = [self sendProperties:url_ sessionKey:sessionKey__ properties:props_ error:&err];
                
                if (!ret)
                {
                    // inform the delegate
                    if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didFailSendingProperties:properties:error:)])
                    {
                        [self.dataSubmitterDelegate didFailSendingProperties:self properties:props_ error:err];
                    }
                }
                else
                {
                    // inform the delegate
                    if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didFinishSendingProperties:properties:)])
                    {
                        [self.dataSubmitterDelegate didFinishSendingProperties:self properties:props_];
                    }
                }
            }
            @catch (NSException *e)
            {
                LogError(@"Unhandled exception: %@", e);
                lassert(false);
                
                NSError *errl = [NSError errorWithDomainAndDescription:kLDatSubmitterErrorDomain
                                                             errorCode:LDataSubmitterStateErrorGeneric
                                                  localizedDescription:LLocalizedString([NSString stringWithFormat:@"Unhandled exception while sending properties: %@", [e reason]])];
                
                // inform the delegate
                if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didFailSendingProperties:properties:error:)])
                {
                    [self.dataSubmitterDelegate didFailSendingProperties:self properties:props_ error:errl];
                }
            }
            @finally
            {
                @synchronized(self.activeSessionsLock)
                {
                    self.activeSessions--;
                    
                    // check / inform sending end
                    [self checkAndInformOnSendingEnd];
                }
            }
        });
    }
    
    // pool files
    if (files_ && [files_ count])
    {
        for(NSString *groupName in files_)
        {
            NSArray *ffiles = [files_ objectForKey:groupName];
            
            if (ffiles && [ffiles count])
            {
                for(NSString *filename in ffiles)
                {
                    // check if cancelled
                    if (_cancelFlag)
                    {
                        break;
                    }
                    
                    @synchronized(_activeSessionsLock)
                    {
                        _activeSessions++;
                    }
                    
                    dispatch_async(_sendQueue, ^{
                        
                        // check if cancelled
                        if (self.cancelFlag)
                        {
                            return;
                        }
                        
                        // inform the delegate
                        if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(willBeginSendingFile:groupName:filename:)])
                        {
                            [self.dataSubmitterDelegate willBeginSendingFile:self groupName:groupName filename:filename];
                        }
                        
                        @try
                        {
                            NSError *err = nil;
                            BOOL ret = [self sendFile:url_ sessionKey:sessionKey__ groupName:groupName filename:filename error:&err];
                            
                            if (!ret)
                            {
                                // inform the delegate
                                if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didFailSendingFile:groupName:filename:error:)])
                                {
                                    [self.dataSubmitterDelegate didFailSendingFile:self groupName:groupName filename:filename error:err];
                                }
                            }
                            else
                            {
                                // inform the delegate
                                if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didFinishSendingFile:groupName:filename:)])
                                {
                                    [self.dataSubmitterDelegate didFinishSendingFile:self groupName:groupName filename:filename];
                                }
                            }
                        }
                        @catch (NSException *e)
                        {
                            LogError(@"Unhandled exception: %@", e);
                            lassert(false);
                            
                            NSError *errl = [NSError errorWithDomainAndDescription:kLDatSubmitterErrorDomain
                                                                         errorCode:LDataSubmitterStateErrorGeneric
                                                              localizedDescription:LLocalizedString([NSString stringWithFormat:@"Unhandled exception while sending file (%@/%@): %@",
                                                                                                     groupName,
                                                                                                     filename,
                                                                                                     [e reason]])];
                            
                            // inform the delegate
                            if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didFailSendingFile:groupName:filename:error:)])
                            {
                                [self.dataSubmitterDelegate didFailSendingFile:self groupName:groupName filename:filename error:errl];
                            }
                        }
                        @finally
                        {
                            @synchronized(self.activeSessionsLock)
                            {
                                self.activeSessions--;
                                
                                // check / inform sending end
                                [self checkAndInformOnSendingEnd];
                            }
                        }
                    });
                }
            }
        }
    }
    
    return YES;
}

- (void)cancel
{
    if (_cancelFlag)
    {
        return;
    }
    
    if (self.state != LDataSubmitterStateWorking)
    {
        return;
    }
}

- (void)checkAndInformOnSendingEnd
{
    // we are in a synchronized lock over _activeSessions here!
    
    lassert(_activeSessions >= 0);
    lassert(self.state == LDataSubmitterStateWorking);
    
    if (_activeSessions <= 0)
    {
        // set the state to finished
        self.state = LDataSubmitterStateIdle;
        _activeSessions = 0;
        
        // inform the delegate
        if (self.dataSubmitterDelegate && [self.dataSubmitterDelegate respondsToSelector:@selector(didFinishSending:)])
        {
            [self.dataSubmitterDelegate didFinishSending:self];
        }
    }
}

#pragma mark - Network Sending

- (BOOL)sendProperties:(NSURL*)url sessionKey:(NSString*)sessionKey_ properties:(NSDictionary*)properties_ error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!url || [NSString isNullOrEmpty:sessionKey_] || !properties_)
    {
        lassert(false);
        return NO;
    }
    
    if (![properties_ count])
    {
        return YES;
    }
    
    // workout the props
    NSMutableDictionary *nd = [NSMutableDictionary dictionary];
    
    for (NSString *groupName in properties_)
    {
        NSDictionary *props = [properties_ objectForKey:groupName];
        
        if (!props || [props isEqual:[NSNull null]] || ![props count])
        {
            continue;
        }
        
        // convert all to string and append group name
        for (NSString *propKey in props)
        {
            NSString *val = [props objectForKey:propKey];
            
            NSString *postKey = [NSString stringWithFormat:@"%@[%@]", groupName, propKey];
            [nd setObject:val forKey:postKey];
        }
    }
    
    if (!nd || ![nd count])
    {
        return YES;
    }
    
    BOOL ret = [self sendNetworkData:url sessionKey:sessionKey_ postParams:nd postFiles:nil error:error];
    
    return ret;
}

- (BOOL)sendFile:(NSURL*)url sessionKey:(NSString*)sessionKey_ groupName:(NSString*)groupName filename:(NSString*)filename error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!url || [NSString isNullOrEmpty:sessionKey_] || [NSString isNullOrEmpty:filename] || [NSString isNullOrEmpty:groupName])
    {
        lassert(false);
        return NO;
    }
    
    // send the groupName within the post params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            groupName, [NSString stringWithFormat:@"%@[%@]", kLDataSubmitterFilesGroupPostKey, [filename lastPathComponent]],
                            nil];
    
    // create the file
    LUrlDownloaderPostFile *pf = [[LUrlDownloaderPostFile alloc] initWithFilename:filename];
    NSArray *files = [NSArray arrayWithObject:pf];
    BOOL ret = [self sendNetworkData:url sessionKey:sessionKey_ postParams:params postFiles:files error:error];
    
    return ret;
}

- (BOOL)sendNetworkData:(NSURL*)url sessionKey:(NSString*)sessionKey_ postParams:(NSDictionary*)postParams postFiles:(NSArray*)postFiles error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!url || !sessionKey_)
    {
        lassert(false);
        return NO;
    }
    
    LUrlDownloader *downloader = [[LUrlDownloader alloc] initWithUrl:url downloadTo:nil requestMethod:LUrlDownloadRequestMethodPost timeout:self.connectionTimeout];
    
    NSMutableDictionary *pd = [NSMutableDictionary dictionaryWithDictionary:postParams];
    
    // add the session key
    [pd setObject:sessionKey_ forKey:kLDataSubmitterSessionKeyPostKey];
    
    downloader.downloadDelegate = self;
    downloader.postParams = pd;
    downloader.postFiles = postFiles;
    downloader.userAgent = self.userAgent;
    downloader.requestHeaders = self.requestHeaders;
    
    BOOL ret =  NO;
    
    @try
    {
        ret = [downloader startDownload:error];
        downloader.downloadDelegate = nil;
    }
    @finally
    {
        downloader = nil;
    }
    
    
    return ret;
}

#pragma mark - LUrlDownloaderDelegate methods

- (void)downloader:(LUrlDownloader*)downloader didSendData:(NSData*)sentData
{
    // check for the cancel flag and stop downloader if cancelled
    if (_cancelFlag)
    {
        [downloader cancel];
    }
}

#pragma mark - Misc

- (NSString*)generateSessionKey
{
    NSString *key = [NSString randomString:kLDataSubmitterDefaultSessionKeyLength];
    return key;
}

#pragma mark - Props / Files management

- (void)setFilesForGroup:(NSString*)groupName files:(NSArray*)filenames
{
    if ([NSString isNullOrEmpty:groupName] || !filenames || ![filenames count])
    {
        lassert(false);
        return;
    }
    
    NSMutableArray *fg = [_files objectForKey:groupName] ? [_files objectForKey:groupName] : [NSMutableArray array];
    
    [fg removeAllObjects];
    [fg addObjectsFromArray:filenames];
    
    [_files setObject:fg forKey:groupName];
}

- (void)setFileForGroup:(NSString*)groupName filename:(NSString*)filename
{
    if ([NSString isNullOrEmpty:groupName] || [NSString isNullOrEmpty:filename])
    {
        lassert(false);
        return;
    }
    
    if ([NSString isNullOrEmpty:groupName])
    {
        lassert(false);
        return;
    }
    
    NSMutableArray *fg = [_files objectForKey:groupName] ? [_files objectForKey:groupName] : [NSMutableArray array];
    
    if ([fg containsObject:filename])
    {
        return;
    }
    
    [fg addObject:filename];
    
    [_files setObject:fg forKey:groupName];
}

- (void)setPropertiesForGroup:(NSString*)groupName properties:(NSDictionary*)properties_
{
    if ([NSString isNullOrEmpty:groupName] || !properties_)
    {
        lassert(false);
        return;
    }
    
    [_properties setObject:properties_ forKey:groupName];
}

- (void)setPropertyForGroup:(NSString*)groupName key:(NSString*)key value:(id)value
{
    if ([NSString isNullOrEmpty:groupName] || [NSString isNullOrEmpty:key] || !value)
    {
        lassert(false);
        return;
    }
    
    NSMutableDictionary *d = [_properties objectForKey:groupName] ? [_properties objectForKey:groupName] : [NSMutableDictionary dictionary];
    
    [d setObject:value forKey:key];
    
    [_properties setObject:d forKey:groupName];
}

- (void)setFile:(NSString*)filename
{
    [self setFileForGroup:kLDataSubmitterDefaultGroup filename:filename];
}

- (void)setProperty:(NSString*)key value:(id)value
{
    [self setPropertyForGroup:kLDataSubmitterDefaultGroup key:key value:value];
}

- (NSDictionary*)propertiesForGroup:(NSString*)groupName
{
    if (![NSString isNullOrEmpty:groupName])
    {
        lassert(false);
        return nil;
    }
    
    return [_properties objectForKey:groupName];
}

- (NSArray*)filesForGroup:(NSString*)groupName
{
    if (![NSString isNullOrEmpty:groupName])
    {
        lassert(false);
        return nil;
    }
    
    return [_files objectForKey:groupName];
}

- (void)removeAllFiles
{
    [_files removeAllObjects];
}

- (void)removeAllProperties
{
    [_properties removeAllObjects];
}

- (void)removeGroup:(NSString*)groupName
{
    if (![NSString isNullOrEmpty:groupName])
    {
        lassert(false);
        return;
    }
    
    [_files removeObjectForKey:groupName];
    [_properties removeObjectForKey:groupName];
}

@end
