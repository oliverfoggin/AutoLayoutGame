//
// Created by Oliver Foggin on 17/05/2013.
// Copyright (c) 2013 Oliver Foggin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

static NSString *JewelTappedNotification = @"JewelTappedNotification";
static NSString *JewelSwipedRightNotification = @"JewelSwipedRightNotification";
static NSString *JewelSwipedLeftNotification = @"JewelSwipedLeftNotification";

@interface JewelView : UIView

- (id)initWithColor:(UIColor *)color;

@property (nonatomic, strong) UIColor *color;

@end