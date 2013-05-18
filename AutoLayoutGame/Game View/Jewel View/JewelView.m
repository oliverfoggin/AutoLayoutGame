//
// Created by Oliver Foggin on 17/05/2013.
// Copyright (c) 2013 Oliver Foggin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "JewelView.h"

@interface JewelView ()

@end

@implementation JewelView

- (id)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.backgroundColor = color;

        UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight)];
        [rightSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:rightSwipeGestureRecognizer];

        UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft)];
        [leftSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:leftSwipeGestureRecognizer];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tapGestureRecognizer];

        [self setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
    return self;
}

- (void)tapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JewelTappedNotification object:self];
}

- (void)swipedRight
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JewelSwipedRightNotification object:self];
}

- (void)swipedLeft
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JewelSwipedLeftNotification object:self];
}

@end