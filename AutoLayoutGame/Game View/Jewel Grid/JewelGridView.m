//
// Created by Oliver Foggin on 17/05/2013.
// Copyright (c) 2013 Oliver Foggin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "JewelGridView.h"
#import "JewelView.h"

@interface JewelGridView ()

@property (nonatomic, strong) NSMutableArray *jewelColumns;
@property (nonatomic) NSUInteger numberOfColumns;
@property (nonatomic) NSUInteger numberOfRows;

@end

@implementation JewelGridView

- (void)awakeFromNib
{
    self.clipsToBounds = YES;

    self.numberOfColumns = 6;
    self.numberOfRows = 9;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelTapped:) name:JewelTappedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelSwipedRight:) name:JewelSwipedRightNotification object:nil];

    [self setupJewels];
}

- (void)setupJewels
{
    self.jewelColumns = [[NSMutableArray alloc] initWithCapacity:self.numberOfColumns];

    for (int i = 0 ; i < self.numberOfColumns ; ++i) {
        NSMutableArray *column = [[NSMutableArray alloc] init];

        [self.jewelColumns addObject:column];
    }
}

- (void)jewelTapped:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[JewelView class]]) {
        JewelView *tappedJewel = notification.object;
        [self removeJewel:tappedJewel];
    }
}

- (void)replaceMissingJewels
{
    for (NSMutableArray *column in self.jewelColumns) {
        int missingJewelCount = self.numberOfRows - [column count];
        for (int i = 0 ; i < missingJewelCount ; ++i) {
            [self addJewelViewToColumnIndex:[self.jewelColumns indexOfObject:column]];
        }
    }
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
        [self replaceMissingJewels];
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
                                                          constant:20 + [self.jewelColumns indexOfObject:jewelColumn] * ([self columnWidth] + 8)]];

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
    NSMutableArray *jewelColumn = self.jewelColumns[index];

    if ([jewelColumn count] == self.numberOfRows) {
        return;
    }

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
                                                          constant:-CGRectGetMinY(previous.frame)];

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
    [self addConstraint:spacingConstraint];

    [self layoutIfNeeded];

    [jewelColumn addObject:jewelView];


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
                         [self replaceMissingJewels];
                     }];
}

- (NSMutableArray *)columnWithJewelView:(JewelView *)jewelView
{
    for (NSMutableArray *column in self.jewelColumns) {
        if ([column containsObject:jewelView]) {
            return column;
        }
    }
    return nil;
}

- (void)jewelSwipedRight:(NSNotification *)notification
{
    JewelView *leftJewel = notification.object;

    NSMutableArray *leftColumn = [self columnWithJewelView:leftJewel];

    int columnIndex = [self.jewelColumns indexOfObject:leftColumn];

    if (columnIndex == [self.jewelColumns count] - 1) {
        return;
    }

    NSMutableArray *rightColumn = self.jewelColumns[columnIndex + 1];

    JewelView *rightJewel = rightColumn[[leftColumn indexOfObject:leftJewel]];

    int rowIndex = [leftColumn indexOfObject:leftJewel];

    NSLayoutConstraint *leftLeftEdgeConstraint;
    NSLayoutConstraint *rightLeftEdgeConstraint;
    NSLayoutConstraint *leftNextAlignmentConstraint;
    NSLayoutConstraint *rightNextAlignmentConstraint;
    NSLayoutConstraint *leftPrevAlignmentConstraint;
    NSLayoutConstraint *rightPrevAlignmentConstraint;

    JewelView *leftPrev = nil;
    JewelView *rightPrev = nil;
    JewelView *leftNext = nil;
    JewelView *rightNext = nil;

    if ([leftColumn count] == 1) {

    } else if (rowIndex == [leftColumn count] - 1) {
        leftPrev = leftColumn[rowIndex - 1];
        rightPrev = rightColumn[rowIndex - 1];
    } else if (rowIndex == 0) {
        leftNext = leftColumn[1];
        rightNext = rightColumn[1];
    } else {
        leftNext = leftColumn[rowIndex + 1];
        leftPrev = leftColumn[rowIndex - 1];
        rightNext = rightColumn[rowIndex + 1];
        rightPrev = rightColumn[rowIndex - 1];
    }

    for (NSLayoutConstraint *constraint in [self constraints]) {
        // left column
        if (constraint.firstItem == leftJewel && constraint.secondItem == self
                && constraint.firstAttribute == NSLayoutAttributeLeft) {
            [self removeConstraint:constraint];
        }

        if (constraint.firstItem == leftNext && constraint.secondItem == leftJewel) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom
                    || constraint.firstAttribute == NSLayoutAttributeWidth) {
                [self removeConstraint:constraint];
            }
        }

        if (constraint.firstItem == leftJewel && constraint.secondItem == leftPrev) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom
                    || constraint.firstAttribute == NSLayoutAttributeWidth) {
                [self removeConstraint:constraint];
            }
        }

        // right column
        if (constraint.firstItem == rightJewel && constraint.secondItem == self
                && constraint.firstAttribute == NSLayoutAttributeLeft) {
            [self removeConstraint:constraint];
        }

        if (constraint.firstItem == rightNext && constraint.secondItem == rightJewel) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom
                    || constraint.firstAttribute == NSLayoutAttributeWidth) {
                [self removeConstraint:constraint];
            }
        }

        if (constraint.firstItem == rightJewel && constraint.secondItem == rightPrev) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom
                    || constraint.firstAttribute == NSLayoutAttributeWidth) {
                [self removeConstraint:constraint];
            }
        }
    }

    //left jewel moving right
    if (rightPrev) {
        rightPrevAlignmentConstraint = [NSLayoutConstraint constraintWithItem:leftJewel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:rightPrev
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:-([self columnWidth] + 8)];
        [self addConstraint:rightPrevAlignmentConstraint];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:leftJewel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:rightPrev
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:-8]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:leftJewel
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:rightPrev
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
    } else {
        leftLeftEdgeConstraint = [NSLayoutConstraint constraintWithItem:leftJewel
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:20 + [self.jewelColumns indexOfObject:leftColumn] * ([self columnWidth] + 8)];
        [self addConstraint:leftLeftEdgeConstraint];
    }

    if (rightNext) {
        rightNextAlignmentConstraint = [NSLayoutConstraint constraintWithItem:rightNext
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:leftJewel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:rightNext.center.x - leftJewel.center.x];
        [self addConstraint:rightNextAlignmentConstraint];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:rightNext
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:leftJewel
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:-8]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:rightNext
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:leftJewel
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0]];
    }

    //right jewel moving left
    if (leftPrev) {
        leftPrevAlignmentConstraint = [NSLayoutConstraint constraintWithItem:rightJewel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:leftPrev
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:[self columnWidth] + 8];
        [self addConstraint:leftPrevAlignmentConstraint];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:rightJewel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:leftPrev
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:-8]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:rightJewel
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:leftPrev
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
    } else {
        rightLeftEdgeConstraint = [NSLayoutConstraint constraintWithItem:rightJewel
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0
                                                                constant:20 + [self.jewelColumns indexOfObject:rightColumn] * ([self columnWidth] + 8)];
        [self addConstraint:rightLeftEdgeConstraint];
    }

    if (leftNext) {
        leftNextAlignmentConstraint = [NSLayoutConstraint constraintWithItem:leftNext
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:rightJewel
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:-([self columnWidth] + 8)];
        [self addConstraint:leftNextAlignmentConstraint];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:leftNext
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:rightJewel
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:-8]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:leftNext
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:rightJewel
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0]];
    }

    [leftColumn replaceObjectAtIndex:rowIndex withObject:rightJewel];
    [rightColumn replaceObjectAtIndex:rowIndex withObject:leftJewel];

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         leftLeftEdgeConstraint.constant = 20 + [self.jewelColumns indexOfObject:rightColumn] * ([self columnWidth] + 8);
                         rightNextAlignmentConstraint.constant = 0;
                         rightPrevAlignmentConstraint.constant = 0;

                         rightLeftEdgeConstraint.constant = 20 + [self.jewelColumns indexOfObject:leftColumn] * ([self columnWidth] + 8);
                         leftNextAlignmentConstraint.constant = 0;
                         leftPrevAlignmentConstraint.constant = 0;

                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {

                     }];
}

@end