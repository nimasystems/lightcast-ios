//
//  LCoreTabBarSelectionView.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LCoreTabBarSelectionView.h"

@implementation LCoreTabBarSelectionView

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowRadius = 1.;
        self.layer.shadowColor = [[UIColor whiteColor] CGColor];
        self.layer.shadowOpacity = 0.4;
        self.clipsToBounds = NO;
    }
    return self;
}

#pragma mark - View Related

- (void)layoutSubviews
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self drawInnerShadowInRect:rect fillColor:[UIColor colorWithHex:0x252525]];
}

@end
