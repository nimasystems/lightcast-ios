//
//  LCoreTabBarControllerTab.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Lightcast/LBadgeView.h>

#if NS_BLOCKS_AVAILABLE
typedef void(^LCoreTabBarExecutionBlock)(void);
#endif

extern CGFloat const kLCoreTabBarControllerTabDefaultTabMargin;

typedef enum
{
    LCoreTabBarViewTextPositionRight,
    LCoreTabBarViewTextPositionBottom
    
} LCoreTabBarViewTextPosition;

@interface LCoreTabBarControllerTab : UIButton <LBadgeViewDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;

@property (nonatomic) CGFloat fixedWidth;
@property (nonatomic) CGFloat fixedHeight;

@property (nonatomic, strong, setter = setFont:) UIFont *font;
@property (nonatomic, assign) LCoreTabBarViewTextPosition textPosition;
@property (nonatomic, strong, setter = setTextColor:) UIColor *textColor;
@property (nonatomic, strong, setter = setSelectedTextColor:) UIColor *selectedTextColor;
@property (nonatomic, assign, setter = setPadding:) CGSize padding;
@property (nonatomic, assign, setter = setMargin:) CGFloat margin;

@property (nonatomic, strong, setter = setBadgeView:) LBadgeView *badgeView;
@property (nonatomic, copy, setter = setBadgeValue:) NSString *badgeValue;
@property (nonatomic, assign, setter = setBadgeOffset:) CGSize badgeOffset;

@property (nonatomic, assign, setter = setShadowVisible:) BOOL shadowVisible;
@property (nonatomic, strong, setter = setShadowColor:) UIColor *shadowColor;

@property (nonatomic, assign) BOOL showsHighlight;

- (id)initWithTitle:(NSString *)title_ icon:(UIImage *)icon_;
- (id)initWithTitle:(NSString *)title_ icon:(UIImage *)icon_ selectedIcon:(UIImage*)selectedIcon_;

-(BOOL)isSelectedTabItem;

+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon;
+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage*)selectedIcon;

+ (LCoreTabBarControllerTab*)tabItemWithFixedWidth:(CGFloat)fixedWidth;

#if NS_BLOCKS_AVAILABLE

@property (nonatomic,copy) LCoreTabBarExecutionBlock executeBlock;

+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon executeBlock:(LCoreTabBarExecutionBlock)executeBlock;
+ (LCoreTabBarControllerTab*)tabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage *)selectedIcon executeBlock:(LCoreTabBarExecutionBlock)executeBlock;

#endif

@end
