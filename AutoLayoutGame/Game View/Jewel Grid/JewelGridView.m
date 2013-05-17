//
// Created by Oliver Foggin on 17/05/2013.
// Copyright (c) 2013 Oliver Foggin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "JewelGridView.h"
#import "JewelView.h"

@interface JewelGridView ()

@property (nonatomic, strong) NSMutableArray *jewelRows;
@property (nonatomic) NSUInteger numberOfColumns;

@end

@implementation JewelGridView

- (void)awakeFromNib
{
    self.clipsToBounds = YES;

    self.numberOfColumns = 6;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelTapped:) name:JewelTappedNotification object:nil];

    [self setupJewels];
}

- (void)setupJewels
{
    self.jewelRows = [[NSMutableArray alloc] initWithCapacity:self.numberOfColumns];

    for (int i = 0 ; i < self.numberOfColumns ; ++i) {
        NSMutableArray *column = [[NSMutableArray alloc] init];

        [self.jewelRows addObject:column];
    }
}

- (void)jewelTapped:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[JewelView class]]) {
        JewelView *tappedJewel = notification.object;
        [self removeJewel:tappedJewel];
    }
}

- (void)addJewelView
{
    int minColumnIndex;
    int minCount = (int) MAXFLOAT;

    for (NSArray *column in self.jewelRows) {
        if ([column count] < minCount) {
            minCount = [column count];
            minColumnIndex = [self.jewelRows indexOfObject:column];
        }
    }

    [self addJewelViewToColumnIndex:minColumnIndex];
}

- (void)removeJewel:(JewelView *)jewelView
{
    NSMutableArray *jewelColumn = [self columnWithJewelView:jewelView];

    int index = [jewelColumn indexOfObject:jewelView];

    JewelView *next = nil;
    JewelView *previous = nil;

    if (index == [jewelColumn count] - 1) {
        [jewelView removeFromSuperview];
        [jewelColumn removeObject:jewelView];
        return;
    } else if (index == 0) {
        next = jewelColumn[1];
    } else {
        next = jewelColumn[index + 1];
        previous = jewelColumn[index - 1];
    }

    [jewelView removeFromSuperview];
    [jewelColumn removeObject:jewelView];

    NSLayoutConstraint *spacingConstraint;

    if (previous) {
        spacingConstraint = [NSLayoutConstraint constraintWithItem:next
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:previous
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:next.center.y - previous.center.y];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:next
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:previous
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:next
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:previous
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];

    } else {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:next
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:20 + [self.jewelRows indexOfObject:jewelColumn] * ([self columnWidth] + 8)]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:next
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:[self columnWidth]]];

        spacingConstraint = [NSLayoutConstraint constraintWithItem:next
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:CGRectGetMaxY(self.bounds) - CGRectGetMaxY(next.frame)];
    }

    [self addConstraint:spacingConstraint];

    [self animateConstraint:previous spacingConstraint:spacingConstraint];

}

- (void)addJewelViewToColumnIndex:(int)index
{
    NSMutableArray *jewelColumn = self.jewelRows[index];

    JewelView *jewelView = [[JewelView alloc] initWithColor:[self randomColor]];
    [self addSubview:jewelView];

    NSLayoutConstraint *spacingConstraint;

    JewelView *previous;

    if ([jewelColumn count] > 0) {
        previous = [jewelColumn lastObject];

        spacingConstraint = [NSLayoutConstraint constraintWithItem:jewelView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:previous
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:CGRectGetMinX(previous.frame)];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:jewelView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:previous
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:jewelView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:previous
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
    } else {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:jewelView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:20 + index * ([self columnWidth] + 8)]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:jewelView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:[self columnWidth]]];

        spacingConstraint = [NSLayoutConstraint constraintWithItem:jewelView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-self.frame.size.height];
    }

    [self layoutIfNeeded];

    [jewelColumn addObject:jewelView];

    [self addConstraint:spacingConstraint];

    [self animateConstraint:previous spacingConstraint:spacingConstraint];
}

- (float)columnWidth
{
    return (self.frame.size.width - 40 - (self.numberOfColumns - 1) * 8)/ self.numberOfColumns;
}

- (UIColor *)randomColor
{
    float red = arc4random_uniform(255);
    float green = arc4random_uniform(255);
    float blue = arc4random_uniform(255);

    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

- (void)animateConstraint:(JewelView *)prev spacingConstraint:(NSLayoutConstraint *)spacingConstraint
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         spacingConstraint.constant = prev ? -8 : -20;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {

                     }];
}

- (NSMutableArray *)columnWithJewelView:(JewelView *)jewelView
{
    for (NSMutableArray *column in self.jewelRows) {
        if ([column containsObject:jewelView]) {
            return column;
        }
    }
    return nil;
}

- (JewelView *)bottomOfColumn:(int)index
{
    if (index < 0
            || index >= [self.jewelRows count]) {
        return nil;
    }

    NSArray *leftColumn = self.jewelRows[index - 1];

    if ([leftColumn count] == 0) {
        return nil;
    }

    return leftColumn[0];
}

@end