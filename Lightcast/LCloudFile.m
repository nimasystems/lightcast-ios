//
//  LCloudFile.m
//  Lightcast
//
//  Created by Dimitrinka Ivanova on 1/29/14.
//  Copyright (c) 2014 Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LCloudFile.h"

@implementation LCloudFile

@synthesize
filename,
iCloudPath,
filePathInApp,
overwriteIfExisting,
formatFile;

#pragma mark - Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        //
    }
    return self;
}

- (void)dealloc
{
    filename = nil;
    iCloudPath = nil;
    filePathInApp = nil;
    formatFile = nil;
}

@end
