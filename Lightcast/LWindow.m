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
 * @changed $Id: LWindow.m 219 2013-02-01 17:30:04Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 219 $
 */

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LWindow.h"

@implementation LWindow

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:LWindowShakeBegan object:self];
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:LWindowShakeCancelled object:self];
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:LWindowShakeEnded object:self];
}

@end
