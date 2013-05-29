//
// Created by Oliver Foggin on 17/05/2013.
// Copyright (c) 2013 Oliver Foggin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

@protocol JewelGridDelegate <NSObject>

- (void)removedJewels:(NSUInteger)numberOfJewelsRemoved;

@end

@interface JewelGridView : UIView

- (void)replaceMissingJewels;

@property (nonatomic, weak) id <JewelGridDelegate> delegate;

@end