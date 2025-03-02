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
 * @changed $Id: UITableView+Additions.m 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "UITableView+Additions.h"

@implementation UITableView(LAdditions)

- (UIView*)indexView {
    Class indexViewClass = NSClassFromString(@"UITableViewIndex");
    NSEnumerator* e = [self.subviews reverseObjectEnumerator];
    for (UIView* child; child = [e nextObject]; ) {
        if ([child isKindOfClass:indexViewClass]) {
            return child;
        }
    }
    return nil;
}

- (CGFloat)tableCellMargin {
    if (self.style == UITableViewStyleGrouped) {
        return 10;
    } else {
        return 0;
    }
}

- (void)scrollToTop:(BOOL)animated {
    [self setContentOffset:CGPointMake(0,0) animated:animated];
}

- (void)scrollToBottom:(BOOL)animated {
    NSUInteger sectionCount = [self numberOfSections];
    if (sectionCount) {
        NSUInteger rowCount = [self numberOfRowsInSection:0];
        if (rowCount) {
            NSUInteger ii[2] = {0, rowCount-1};
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom
                                animated:animated];
        }
    }
}

- (void)scrollToFirstRow:(BOOL)animated {
    if ([self numberOfSections] > 0 && [self numberOfRowsInSection:0] > 0) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop
                            animated:NO];
    }
}

- (void)scrollToLastRow:(BOOL)animated {
    if ([self numberOfSections] > 0) {
        NSInteger section = [self numberOfSections]-1;
        NSInteger rowCount = [self numberOfRowsInSection:section];
        if (rowCount > 0) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:section];
            [self scrollToRowAtIndexPath:indexPath
                        atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

- (void)scrollFirstResponderIntoView {
    UIView* responder = [self.window findFirstResponder];
    UITableViewCell* cell = (UITableViewCell*)[responder ancestorOrSelfWithClass:[UITableViewCell class]];
    if (cell) {
        NSIndexPath* indexPath = [self indexPathForCell:cell];
        if (indexPath) {
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
                                animated:YES];
        }
    }
}

- (void)touchRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated {
    if (![self cellForRowAtIndexPath:indexPath]) {
        [self reloadData];
    }
    
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
    }
    
    [self selectRowAtIndexPath:indexPath animated:animated
                scrollPosition:UITableViewScrollPositionTop];
    
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}

@end
