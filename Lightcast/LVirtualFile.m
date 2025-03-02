/*
 * Lightcast for iOS Framework
 * Copyright (C) 2007-2011 Nimasystems Ltd
 *
 * This program is NOT free software; you cannot redistribute and/or modify
 * it's sources under any circumstances without the explicit knowledge and
 * agreement of the rightful owner of the software - Nimasystems Ltd.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the LICENSE.txt file for more information.
 *
 * You should have received a copy of LICENSE.txt file along with this
 * program; if not, write to:
 * NIMASYSTEMS LTD 
 * Plovdiv, Bulgaria
 * ZIP Code: 4000
 * Address: 95 "Kapitan Raycho" Str., 6th Floor
 * General E-Mail: info@nimasystems.com
 * Tel./Fax: +359 32 395 282
 * Mobile: +359 896 610 876
 */

/**
 * File Description
 * @package File Category
 * @subpackage File Subcategory
 * @changed $Id: LVirtualFile.m 292 2013-08-29 14:11:56Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 292 $
 */

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LVirtualFile.h"

@interface LVirtualFile(Private)

- (NSString *)fullFileName;

@end

@implementation LVirtualFile

@synthesize 
fileId,
fileName,
pathToVfs,
dirHash,
fileHash,
fileType,
filesize,
createdOn,
fullPath;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        fileId = 0;
        fileName = nil;
        pathToVfs = nil;
        dirHash = nil;
        fileHash = nil;
        createdOn = nil;
        fileType = nil;
    }
    return self;
}

- (void)dealloc {
    pathToVfs = nil;
    fileName = nil;
    dirHash = nil;
    fileHash = nil;
    fileType = nil;
    createdOn = nil;
}

#pragma mark -
#pragma mark Other

- (NSString*)description {
    
    return [NSString stringWithFormat:
            @"ID: %d\n\
            Filename: %@\n\
            Dir hash: %@\n\
            File hash: %@\n\
            Type: %@\n\
            Size: %lld\n\
            Created on: %@\n", (int)fileId, fileName, dirHash, fileHash, fileType, filesize, createdOn];
}

- (NSData *)getFileData {
    
    // try to load the contents of the file and return them as data
    
    NSData * data = [NSData dataWithContentsOfFile:[self fullFileName]];
    
    return data;
}

#pragma mark -
#pragma mark Private

- (NSString *)fullFileName {
    
    if (!dirHash || !fileHash || !fileType) return nil;
    
    NSString * p = [NSString stringWithString:pathToVfs];
    p = [p stringByAppendingPathComponent:dirHash];
    p = [p stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileHash, fileType]];
    
    return p;
}

@end
