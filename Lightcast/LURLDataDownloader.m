//
//  LURLDataDownloader.m
//  Lightcast
//
//  Created by Martin Kovachev on 04.02.14.
//  Copyright (c) 2014 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LURLDataDownloader.h"

NSTimeInterval const kLURLDataDownloaderDefaultTimeout = 60;

@implementation LURLDataDownloader

@synthesize
cacheDir,
url,
downloader,
downloadedUrl,
timeout;

#pragma mark - Initialization / Finalization

- (id)initWithUrl:(NSURL*)url_ {
    self = [super init];
    if (self) {
        if (!url_) {
            lassert(false);
            return nil;
        }
        
        url = [url_ copy];
        timeout = kLURLDataDownloaderDefaultTimeout;
        downloader = [[LUrlDownloader alloc] initWithUrl:url downloadTo:nil requestMethod:LUrlDownloadRequestMethodGet timeout:timeout];
    }
    return self;
}

- (id)init {
    return [self initWithUrl:nil];
}

- (void)dealloc {
    
    url = nil;
    downloadedUrl = nil;
    cacheDir = nil;
    downloader = nil;
}

+ (LURLDataDownloader*)downloadedUrlData:(NSURL*)url cacheDir:(NSString*)cacheDir {
    if (!url || [NSString isNullOrEmpty:cacheDir]) {
        return nil;
    }
    
    LURLDataDownloader *d = [[LURLDataDownloader alloc] initWithUrl:url];
    d.cacheDir = cacheDir;
    
    return d;
}

#pragma mark - Getters / Setters

- (NSURL*)getDownloadedUrl {
    NSURL *url_ = [NSURL fileURLWithPath:[self filenameFromUrl]];
    return url_;
}

#pragma mark - Helpers

- (NSString*)filenameFromUrl {
    lassert(self.url);
    
    return nil;
}

#pragma mark - Downloading

- (BOOL)startDownloading:(NSError**)error {
    if (error != NULL) {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:cacheDir]) {
        lassert(false);
        return NO;
    }
    
    downloader.downloadPath = self.cacheDir;
    
    
    
    return YES;
}


@end
