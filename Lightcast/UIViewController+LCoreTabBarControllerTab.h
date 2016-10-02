//
//  UIViewController+LCoreTabBarControllerTab.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#ifndef uivc_lcoretabbar
#define uivc_lcoretabbar

#import <Foundation/Foundation.h>
#import <Lightcast/LCoreTabBarController.h>

@interface UIViewController(LCoreTabBarControllerTab)

@property(nonatomic, strong) LCoreTabBarControllerTab *customCoreTabBarItem;

@property(nonatomic, readonly, strong) LCoreTabBarController *coreTabBarController;

@end

#endif
