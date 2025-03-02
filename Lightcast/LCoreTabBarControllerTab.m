//
//  LCoreTabBarControllerTab.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "LCoreTabBarControllerTab.h"
#import "LCoreTabBarView.h"
#import "LCoreTabBarContainerView.h"

CGFloat const kLCoreTabBarControllerTabDefaultTabMargin = 8.0;

@implementation LCoreTabBarControllerTab

@synthesize
title,
icon,
selectedIcon,
textPosition,
fixedWidth,
fixedHeight,
executeBlock,
padding,
font,
textColor,
selectedTextColor,
margin,
showsHighlight,
badgeView,
badgeValue,
badgeOffset,
shadowVisible,
shadowColor;

#pragma mark - Initialization / Finalization

- (id)initWithTitle:(NSString *)title_ icon:(UIImage *)icon_ selectedIcon:(UIImage*)selectedIcon_
{
    self = [super init];
    if (self)
    {
        self.title = title_;
        self.icon = icon_;
        self.selectedIcon = selectedIcon_;
        self.backgroundColor = [UIColor clearColor];
        self.shadowColor = [UIColor grayColor];
        
        self.showsHighlight = YES;
        self.shadowVisible = YES;
        
        [self setIsAccessibilityElement:YES];
        [self setAccessibilityLabel:title];
        
        [self addTarget:self action:@selector(itemTapped) forControlEvents:UIControlEventTouchUpInside];
        
        font = [UIFont boldSystemFontOfSize:12.];
        margin = kLCoreTabBarControllerTabDefaultTabMargin;
        textColor = [UIColor whiteColor];
        
        badgeOffset = CGSizeMake(5, 0);
    }
    return self;
}

- (id)initWithTitle:(NSString *)title_ icon:(UIImage *)icon_
{
    return [self initWithTitle:title_ icon:icon_ selectedIcon:nil];
}

- (void)dealloc;
{
    font = nil;
    textColor = nil;
    selectedTextColor = nil;
    badgeValue = nil;
    icon = nil;
    selectedIcon = nil;
    title = nil;
    executeBlock = nil;
    shadowColor = nil;
    badgeView = nil;
}

+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon
{
    LCoreTabBarControllerTab * tabItem = [[LCoreTabBarControllerTab alloc] initWithTitle:title icon:icon];
    return tabItem;
}

+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage*)selectedIcon
{
    LCoreTabBarControllerTab * tabItem = [[LCoreTabBarControllerTab alloc] initWithTitle:title icon:icon selectedIcon:selectedIcon];
    return tabItem;
}

+ (LCoreTabBarControllerTab*)tabItemWithFixedWidth:(CGFloat)fixedWidth
{
    LCoreTabBarControllerTab * tabItem = [LCoreTabBarControllerTab tabItemWithTitle:nil icon:nil];
    tabItem.fixedWidth = fixedWidth;
    return tabItem;
}

#ifdef NS_BLOCKS_AVAILABLE
+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon executeBlock:(LCoreTabBarExecutionBlock)executeBlock
{
    return [LCoreTabBarControllerTab tabItemWithTitle:title icon:icon selectedIcon:nil executeBlock:executeBlock];
}

+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage *)selectedIcon executeBlock:(LCoreTabBarExecutionBlock)executeBlock
{
    LCoreTabBarControllerTab * tabItem = [LCoreTabBarControllerTab tabItemWithTitle:title icon:icon selectedIcon:selectedIcon];
    tabItem.executeBlock = executeBlock;
    return tabItem;
}
#endif

#pragma mark - Getters / Setters

- (void)setPadding:(CGSize)padding_
{
    if (padding.height != padding_.height || padding.width || padding_.width)
    {
        padding = padding_;
        
        [self setNeedsDisplay];
    } 
}

- (void)setMargin:(CGFloat)margin_
{
    if (margin_ != margin)
    {
        margin = margin_;
        
        [self setNeedsDisplay];
    }
}

- (void)setFont:(UIFont*)font_
{
    if (font != font_)
    {
        font = font_;
        
        [self setNeedsDisplay];
    }
}

- (void)setTextColor:(UIColor*)color_
{
    if (textColor != color_)
    {
        textColor = color_;
        
        [self setNeedsDisplay];
    }
}

- (void)setSelectedTextColor:(UIColor*)color_
{
    if (selectedTextColor != color_)
    {
        selectedTextColor = color_;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeView:(LBadgeView *)badgeView_ {
    if (badgeView != badgeView_) {
        if (badgeView) {
            badgeView.delegate = nil;
            [badgeView removeFromSuperview];
            badgeView = nil;
        }
        
        badgeView = badgeView_;
        badgeView.delegate = self;
        [self addSubview:badgeView];
        
        [self setNeedsLayout];
    }
}

- (void)setBadgeValue:(NSString *)badgeValue_
{
    if (badgeValue_ != badgeValue)
    {
        badgeValue = [badgeValue_ copy];
        
        if ([NSString isNullOrEmpty:badgeValue])
        {
            // remove the view
            if (badgeView)
            {
                [badgeView removeFromSuperview];
            }
        }
        else
        {
            if (!badgeView)
            {
                // create the view
                badgeView = [[LBadgeView alloc] initWithFrame:CGRectNull];
                badgeView.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
                badgeView.delegate = self;
                
                CGFloat bWidth = kLBadgeViewDefaultBorderWidth;
                
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                    bWidth = kLBadgeViewDefaultBorderWidthIOS7;
                }
                
                badgeView.borderWidth = bWidth;
                [self addSubview:badgeView];
                
            } else if (![badgeView superview]) {
                [self addSubview:badgeView];
            }
            
            badgeView.value = badgeValue;
            [badgeView sizeToFit];
        }
        
        [self setNeedsLayout];
    }
}

- (void)setBadgeOffset:(CGSize)badgeOffset_
{
    if (badgeOffset_.height != badgeOffset.height || badgeOffset_.width != badgeOffset.width)
    {
        badgeOffset = badgeOffset_;
        
        [self setNeedsLayout];
    }
}

- (void)setShadowVisible:(BOOL)isVisible
{
    if (isVisible != shadowVisible)
    {
        shadowVisible = isVisible;
        
        [self setNeedsDisplay];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor_
{
    if (shadowColor_ != shadowColor)
    {
        shadowColor = shadowColor_;
        
        [self setNeedsDisplay];
    }
}

#pragma mark - LBadgeViewDelegate methods

- (void)viewTouched:(LBadgeView*)view
{
    [self itemTapped];
}

#pragma mark - View Related

- (void)layoutSubviews
{
    if (badgeView)
    {
        CGRect frm = CGRectMake(round(self.bounds.size.width - (badgeView.frame.size.width / 2 + badgeOffset.width)),
                                round(- (badgeView.frame.size.height / 2 + badgeOffset.height)),
                                badgeView.frame.size.width,
                                badgeView.frame.size.height
                                );
        
        badgeView.frame = frm;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize titleSize = ![NSString isNullOrEmpty:self.title] ? [self.title sizeWithAttributes:@{
                                                                                               NSFontAttributeName : font
                                                                                               }] : CGSizeMake(0, 0);
    
    CGFloat width = titleSize.width;
    
    if (self.icon)
    {
        width += [self.icon size].width;
    }
    
    if (self.title && self.textPosition == LCoreTabBarViewTextPositionRight)
    {
        width += margin;
    }
    
    width += (self.padding.width * 2);
    
    CGFloat height = 0.0;
    
    if (self.textPosition == LCoreTabBarViewTextPositionRight)
    {
        height = (titleSize.height > [self.icon size].height) ? titleSize.height : [self.icon size].height;
    }
    else
    {
        height = titleSize.height + self.icon.size.height + margin;
    }
    
    height += (self.padding.height * 2);
    
    if (self.fixedWidth > 0)
    {
        width = self.fixedWidth;
    }
    
    if (self.fixedHeight > 0)
    {
        height = self.fixedHeight;
    }
    
    return CGSizeMake(width, height);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.shadowVisible)
    {
        CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 1.0f, [self.shadowColor CGColor]);
    }
    
    CGContextSaveGState(context);
    
    UIImage *icon_ = ([self isSelectedTabItem] && self.selectedIcon) ? self.selectedIcon : self.icon;
    UIColor *textColor_ = ([self isSelectedTabItem] && self.selectedTextColor) ? self.selectedTextColor : self.textColor;
    
    if (self.showsHighlight && self.highlighted)
    {
        CGRect bounds = CGRectInset(rect, 2., 2.);
        CGFloat radius = 0.5f * CGRectGetHeight(bounds);
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
        [[UIColor colorWithWhite:1. alpha:0.3] set];
        path.lineWidth = 2.;
        [path stroke];
    }
    
    if (self.textPosition == LCoreTabBarViewTextPositionRight)
    {
        CGFloat xOffset = self.padding.width;
        
        if (icon_)
        {
            [icon_ drawAtPoint:CGPointMake(xOffset, self.padding.height)];
            xOffset += [icon_ size].width + margin;
        }
        
        if (![NSString isNullOrEmpty:self.title])
        {
            [textColor_ set];
            
            CGSize textSize = [self.title sizeWithAttributes:@{
                                                               NSFontAttributeName : font
                                                               }];
            CGFloat titleYOffset = round((self.bounds.size.height - textSize.height) / 2);
            xOffset = (icon_) ? xOffset : round(self.bounds.size.width / 2 - textSize.width / 2);
            [self.title drawAtPoint:CGPointMake(xOffset, titleYOffset) withAttributes:@{ NSFontAttributeName : font }];
        }
    }
    else if (self.textPosition == LCoreTabBarViewTextPositionBottom)
    {
        if (icon_)
        {
            [icon_ drawAtPoint:CGPointMake(round(self.bounds.size.width / 2 - icon_.size.width / 2), (self.padding.height*2) + 2)];
        }
        
        if (![NSString isNullOrEmpty:self.title])
        {
            CGFloat yOffset = self.margin;
            
            [textColor_ set];
            
            CGSize textSize = [self.title sizeWithAttributes:@{
                                                               NSFontAttributeName : font
                                                               }];
            [self.title drawAtPoint:CGPointMake(round(self.bounds.size.width / 2 - textSize.width / 2), self.bounds.size.height - 15 + yOffset) withAttributes:@{ NSFontAttributeName : font }];
        }
    }
    
    CGContextRestoreGState(context);
}

#pragma mark - Other

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

-(BOOL)isSelectedTabItem
{
    LCoreTabBarContainerView *tabContainer = (LCoreTabBarContainerView*)[self superview];
    return [tabContainer isItemSelected:self];
}

- (void)itemTapped
{
    LCoreTabBarContainerView *tabContainer = (LCoreTabBarContainerView*)[self superview];
    [tabContainer itemSelected:self];
    
#ifdef NS_BLOCKS_AVAILABLE
    if (executeBlock)
    {
        executeBlock();
    }
#endif
}

@end
