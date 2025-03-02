//
//  LUrlDownloaderPostFile.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LUrlDownloaderPostFile.h"

NSString *const LUrlDownloaderPostFileDefaultMimetype = @"application/octet-stream";

@implementation LUrlDownloaderPostFile {
    
    BOOL _isFile;
}

@synthesize
filename,
data,
mimetype,
dataSize,
actualData;

#pragma mark - Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        lassert(false);
    }
    return self;
}

- (id)initWithFilename:(NSString*)aFilename
{
    self = [super init];
    if (self)
    {
        _isFile = YES;
        
        if ([NSString isNullOrEmpty:aFilename])
        {
            lassert(false);
            return nil;
        }
        
        filename = [aFilename copy];
    }
    return self;
}

- (id)initWithData:(NSData*)someData
{
    self = [super init];
    if (self)
    {
        _isFile = NO;
        
        if (!someData || ![someData length])
        {
            lassert(false);
            return nil;
        }
        
        data = [someData copy];
    }
    return self;
}

- (void)dealloc
{
    filename = nil;
    data = nil;
    actualData = nil;
    mimetype = nil;
}

#pragma mark - Getters / Setters

- (NSString*)getMimetype
{
    // TODO restore this some day
    /*
     __block NSMutableString *mime = [[NSMutableString alloc] init];
     
     // it seems GEMagicResult is not thread safe at all
     // this may cause severe locks!
     // TODO: Remove this from here
     dispatch_sync(dispatch_get_main_queue(), ^{
     @try
     {
     NSString *fn = [[filename copy] autorelease];
     GEMagicResult *result = _isFile ? [GEMagicKit magicForFileAtPath:fn] : [GEMagicKit magicForData:data];
     
     [mime setString:result.mimeType];
     }
     @catch (NSException *e)
     {
     LogError(@"Unhandled exception while quering the GEMagicKit: %@", e);
     }
     });
     
     if ([NSString isNullOrEmpty:mime])
     {
     // fallback to default
     [mime setString:LUrlDownloaderPostFileDefaultMimetype];
     }
     
     
     return [mime autorelease];*/
    
    return LUrlDownloaderPostFileDefaultMimetype;
}

- (long long)getDataSize
{
    long long ds = 0;
    
    if (_isFile)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *err = nil;
        NSDictionary *attributes = [fm attributesOfItemAtPath:filename error:&err];
        lassert(attributes);
        
        if (attributes)
        {
            ds = [[attributes objectForKey:NSFileSize] longLongValue];
        }
    }
    else
    {
        ds = [data length];
    }
    
    return ds;
}

- (NSData*)getActualData
{
    NSData *d = _isFile ? ([NSData dataWithContentsOfFile:filename]) : data;
    return d;
}

@end
