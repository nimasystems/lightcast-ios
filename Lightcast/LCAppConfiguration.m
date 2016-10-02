//
//  LCAppConfiguration.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 21.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import "LCAppConfiguration.h"

@implementation LCAppConfiguration

@synthesize
resourcesPath,
documentsPath,
temporaryPath,
libraryPath,
cachesPath;

#pragma mark - Initialization / Finalization

- (id)initWithPaths:(NSString*)aResourcesPath documentsPath:(NSString*)aDocumentsPath temporaryPath:(NSString*)aTemporaryPath
{
    return [self initWithPaths:aResourcesPath documentsPath:aDocumentsPath temporaryPath:aTemporaryPath libraryPath:nil];
}

- (id)initWithPaths:(NSString*)aResourcesPath documentsPath:(NSString*)aDocumentsPath temporaryPath:(NSString*)aTemporaryPath libraryPath:(NSString*)aLibraryPath
{
    return [self initWithPaths:aResourcesPath documentsPath:aDocumentsPath temporaryPath:aTemporaryPath libraryPath:aLibraryPath cachesPath:nil];
}

- (id)initWithPaths:(NSString*)aResourcesPath documentsPath:(NSString*)aDocumentsPath temporaryPath:(NSString*)aTemporaryPath libraryPath:(NSString*)aLibraryPath cachesPath:(NSString*)aCachesPath
{
    self = [super init];
    if (self)
    {
        resourcesPath = [aResourcesPath copy];
        documentsPath = [aDocumentsPath copy];
        temporaryPath = [aTemporaryPath copy];
        libraryPath = [aLibraryPath copy];
        cachesPath = [aCachesPath copy];
    }
    return self;
}

- (void)dealloc
{
    resourcesPath = nil;
    documentsPath = nil;
    temporaryPath = nil;
    libraryPath = nil;
    cachesPath = nil;
}

#pragma mark - Helpers

- (NSString*)description
{
    NSString *description = [NSString stringWithFormat:@"LCAppConfiguration:\nResourcesPath:%@\nDocumentsPath:%@\nLibraryPath:%@\nCachesPath:%@\nTemporaryPath:%@\n\n%@",
                             resourcesPath,
                             documentsPath,
                             libraryPath,
                             cachesPath,
                             temporaryPath,
                             [super description]
                             ];
    return description;
}

@end
