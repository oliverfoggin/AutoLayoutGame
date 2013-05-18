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
@property (nonatomic, strong) NSArray *colours;

@end

@implementation JewelGridView

- (void)awakeFromNib
{
    self.clipsToBounds = YES;

    self.numberOfColumns = 6;
    self.numberOfRows = 9;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelTapped:) name:JewelTappedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelSwipedRight:) name:JewelSwipedRightNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelSwipedLeft:) name:JewelSwipedLeftNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelSwipedUpward:) name:JewelSwipedUpwardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jewelSwipedDownward:) name:JewelSwipedDownwardNotification object:nil];

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

- (void)replaceMissingJewels
{
    for (NSMutableArray *column in self.jewelColumns) {
        int missingJewelCount = self.numberOfRows - [column count];
        for (int i = 0 ; i < missingJewelCount ; ++i) {
            [self addJewelViewToColumnIndex:[self.jewelColumns indexOfObject:column]];
        }
    }
}

#pragma mark - jewel manipulation

- (void)removeJewel:(JewelView *)jewelView
{
    NSMutableArray *jewelColumn = [self columnWithJewelView:jewelView];

    NSUInteger index = [jewelColumn indexOfObject:jewelView];

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

        spacingConstraint = [NSLayoutConstraint constraintWithItem:next
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:CGRectGetMaxY(self.bounds) - CGRectGetMaxY(next.frame)];
    }

    [self addConstraint:spacingConstraint];

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         spacingConstraint.constant = previous ? -8 : -20;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self replaceMissingJewels];
                     }];
}

- (void)addJewelViewToColumnIndex:(NSUInteger)index
{
    NSMutableArray *jewelColumn = self.jewelColumns[index];

    if ([jewelColumn count] == self.numberOfRows) {
        return;
    }

    JewelView *jewelView = [[JewelView alloc] initWithColor:[self randomColor]];
    [jewelView addConstraint:[NSLayoutConstraint constraintWithItem:jewelView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:[self columnWidth]]];
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
    } else {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:jewelView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:20 + index * ([self columnWidth] + 8)]];

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

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         spacingConstraint.constant = previous ? -8 : -20;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self replaceMissingJewels];
                     }];
}

- (void)swapLeftJewel:(JewelView *)leftJewel
       withRightJewel:(JewelView *)rightJewel
{
    NSMutableArray *leftColumn = [self columnWithJewelView:leftJewel];

    NSMutableArray *rightColumn = [self columnWithJewelView:rightJewel];

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

    NSUInteger rowIndex = [leftColumn indexOfObject:leftJewel];

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
            leftLeftEdgeConstraint = constraint;
        }

        if (constraint.firstItem == leftNext && constraint.secondItem == leftJewel) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom) {
                [self removeConstraint:constraint];
            }
        }

        if (constraint.firstItem == leftJewel && constraint.secondItem == leftPrev) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom) {
                [self removeConstraint:constraint];
            }
        }

        // right column
        if (constraint.firstItem == rightJewel && constraint.secondItem == self
                && constraint.firstAttribute == NSLayoutAttributeLeft) {
            rightLeftEdgeConstraint = constraint;
        }

        if (constraint.firstItem == rightNext && constraint.secondItem == rightJewel) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom) {
                [self removeConstraint:constraint];
            }
        }

        if (constraint.firstItem == rightJewel && constraint.secondItem == rightPrev) {
            if (constraint.firstAttribute == NSLayoutAttributeCenterX
                    || constraint.firstAttribute == NSLayoutAttributeBottom) {
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
    } else {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:leftJewel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-20]];
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
    } else {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:rightJewel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-20]];
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

- (void)swapTopJewel:(JewelView *)aboveJewel
     withBottomJewel:(JewelView *)belowJewel
{
    JewelView *topJewel = [self jewelAboveJewel:aboveJewel];
    JewelView *bottomJewel = [self jewelBelowJewel:belowJewel];

    NSLayoutConstraint *bottomSpacingConstraint;
    NSLayoutConstraint *middleSpacingConstraint;
    NSLayoutConstraint *topSpacingConstraint;
    NSLayoutConstraint *bottomAlignmentConstraint;
    NSLayoutConstraint *middleAlignmentConstraint;
    NSLayoutConstraint *topAlignmentConstraint;

    NSMutableArray *column = [self columnWithJewelView:aboveJewel];

    NSUInteger index = [self.jewelColumns indexOfObject:column];

    for (NSLayoutConstraint *constraint in [self constraints]) {
        if (constraint.firstItem == topJewel && constraint.secondItem == aboveJewel) {
            [self removeConstraint:constraint];
            topSpacingConstraint = [NSLayoutConstraint constraintWithItem:topJewel
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:belowJewel
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:CGRectGetMaxY(topJewel.frame) - CGRectGetMinY(belowJewel.frame)];
        }

        if (constraint.firstItem == aboveJewel && constraint.secondItem == belowJewel
                && constraint.firstAttribute == NSLayoutAttributeBottom) {
            [self removeConstraint:constraint];
            middleSpacingConstraint = [NSLayoutConstraint constraintWithItem:belowJewel
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:aboveJewel
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:CGRectGetMaxY(aboveJewel.frame) - CGRectGetMinY(belowJewel.frame)];
        }

        if (constraint.firstItem == belowJewel && constraint.secondItem == bottomJewel
                && constraint.firstAttribute == NSLayoutAttributeBottom) {
            [self removeConstraint:constraint];
            bottomSpacingConstraint = [NSLayoutConstraint constraintWithItem:aboveJewel
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:bottomJewel
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:CGRectGetMaxY(aboveJewel.frame) - CGRectGetMinY(bottomJewel.frame)];
        }

        if (constraint.firstItem == belowJewel && constraint.secondItem == self
                && constraint.firstAttribute == NSLayoutAttributeBottom) {
            [self removeConstraint:constraint];
            bottomSpacingConstraint = [NSLayoutConstraint constraintWithItem:aboveJewel
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:CGRectGetMaxY(aboveJewel.frame) - CGRectGetMaxY(self.bounds)];
        }

        if (constraint.firstItem == topJewel && constraint.secondItem == aboveJewel
                && constraint.firstAttribute == NSLayoutAttributeCenterX) {
            [self removeConstraint:constraint];
            topAlignmentConstraint = [NSLayoutConstraint constraintWithItem:topJewel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:belowJewel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0];
        }

        if (constraint.firstItem == aboveJewel && constraint.secondItem == belowJewel
                && constraint.firstAttribute == NSLayoutAttributeCenterX) {
            [self removeConstraint:constraint];
            middleAlignmentConstraint = [NSLayoutConstraint constraintWithItem:belowJewel
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:aboveJewel
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0.0];
        }

        if (constraint.firstItem == belowJewel && constraint.secondItem == bottomJewel
                && constraint.firstAttribute == NSLayoutAttributeCenterX) {
            [self removeConstraint:constraint];
            bottomAlignmentConstraint = [NSLayoutConstraint constraintWithItem:aboveJewel
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:bottomJewel
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0.0];
        }

        if (constraint.firstItem == belowJewel && constraint.secondItem == self
                && constraint.firstAttribute == NSLayoutAttributeCenterX) {
            [self removeConstraint:constraint];
            bottomAlignmentConstraint = [NSLayoutConstraint constraintWithItem:aboveJewel
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:20 + index * ([self columnWidth] + 8)];
        }
    }

    [self addConstraint:topAlignmentConstraint];
    [self addConstraint:middleAlignmentConstraint];
    [self addConstraint:bottomAlignmentConstraint];
    [self addConstraint:bottomSpacingConstraint];
    [self addConstraint:middleSpacingConstraint];
    [self addConstraint:topSpacingConstraint];

    [column replaceObjectAtIndex:[column indexOfObject:aboveJewel] withObject:belowJewel];
    [column replaceObjectAtIndex:[column indexOfObject:belowJewel] withObject:aboveJewel];

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         topSpacingConstraint.constant = -8;
                         middleSpacingConstraint.constant = -8;
                         bottomSpacingConstraint.constant = -(bottomJewel ? 8 : 20);
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {

                     }];
}

#pragma mark - check jewels

- (void)checkJewelForRemoval:(JewelView *)jewelView
{
    JewelView *leftJewel = [self jewelLeftOfJewel:jewelView];
    JewelView *rightJewel = [self jewelRightOfJewel:jewelView];
    JewelView *aboveJewel = [self jewelAboveJewel:jewelView];
    JewelView *belowJewel = [self jewelBelowJewel:jewelView];

    if ([leftJewel.color isEqual:jewelView.color]
            && [rightJewel.color isEqual:jewelView.color]) {
        [self removeJewel:jewelView];
        [self removeJewel:leftJewel];
        [self removeJewel:rightJewel];
    } else if ([aboveJewel.color isEqual:jewelView.color]
            && [belowJewel.color isEqual:jewelView.color]) {
        [self removeJewel:jewelView];
        [self removeJewel:aboveJewel];
        [self removeJewel:belowJewel];
    }
}

#pragma mark - jewel attributes

- (float)columnWidth
{
    return (self.frame.size.width - 40 - (self.numberOfColumns - 1) * 8)/ self.numberOfColumns;
}

- (NSArray *)colours
{
    if (_colours == nil) {
        _colours = @[
                [UIColor redColor],
                [UIColor orangeColor],
                [UIColor yellowColor],
                [UIColor greenColor],
                [UIColor blueColor],
                [UIColor purpleColor]
        ];
    }
    return _colours;
}

- (UIColor *)randomColor
{
    return self.colours[arc4random_uniform([self.colours count] - 1)];
}

#pragma mark - jewel actions

- (void)jewelTapped:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[JewelView class]]) {
        JewelView *tappedJewel = notification.object;
        [self removeJewel:tappedJewel];
    }
}

- (void)jewelSwipedRight:(NSNotification *)notification
{
    JewelView *leftJewel = notification.object;
    JewelView *rightJewel = [self jewelRightOfJewel:leftJewel];

    if (rightJewel == nil) {
        return;
    }

    [self swapLeftJewel:leftJewel withRightJewel:rightJewel];
}

- (void)jewelSwipedLeft:(NSNotification *)notification
{
    JewelView *rightJewel = notification.object;
    JewelView *leftJewel = [self jewelLeftOfJewel:rightJewel];

    if (leftJewel == nil) {
        return;
    }

    [self swapLeftJewel:leftJewel withRightJewel:rightJewel];
}

- (void)jewelSwipedUpward:(NSNotification *)notification
{
    JewelView *belowJewel = notification.object;
    JewelView *aboveJewel = [self jewelAboveJewel:belowJewel];

    if (aboveJewel == nil) {
        return;
    }

    [self swapTopJewel:aboveJewel withBottomJewel:belowJewel];
}

- (void)jewelSwipedDownward:(NSNotification *)notification
{
    JewelView *aboveJewel = notification.object;
    JewelView *belowJewel = [self jewelBelowJewel:aboveJewel];

    if (belowJewel == nil) {
        return;
    }

    [self swapTopJewel:aboveJewel withBottomJewel:belowJewel];
}

#pragma mark - jewel navigation

- (NSMutableArray *)columnWithJewelView:(JewelView *)jewelView
{
    for (NSMutableArray *column in self.jewelColumns) {
        if ([column containsObject:jewelView]) {
            return column;
        }
    }
    return nil;
}

- (JewelView *)jewelLeftOfJewel:(JewelView *)jewelView
{
    NSArray *column = [self columnWithJewelView:jewelView];

    NSUInteger columnIndex = [self.jewelColumns indexOfObject:column];

    if (columnIndex == 0) {
        return nil;
    }

    NSArray *leftColumn = self.jewelColumns[columnIndex - 1];

    JewelView *leftJewel = leftColumn[[column indexOfObject:jewelView]];

    return leftJewel;
}

- (JewelView *)jewelRightOfJewel:(JewelView *)jewelView
{
    NSArray *column = [self columnWithJewelView:jewelView];

    NSUInteger columnIndex = [self.jewelColumns indexOfObject:column];

    if (columnIndex == self.numberOfColumns - 1) {
        return nil;
    }

    NSArray *rightColumn = self.jewelColumns[columnIndex + 1];

    JewelView *rightJewel = rightColumn[[column indexOfObject:jewelView]];

    return rightJewel;
}

- (JewelView *)jewelAboveJewel:(JewelView *)jewelView
{
    NSArray *column = [self columnWithJewelView:jewelView];

    NSUInteger rowIndex = [column indexOfObject:jewelView];

    if (rowIndex == self.numberOfRows - 1) {
        return nil;
    }

    JewelView *aboveJewel = column[rowIndex + 1];

    return aboveJewel;
}

- (JewelView *)jewelBelowJewel:(JewelView *)jewelView
{
    NSArray *column = [self columnWithJewelView:jewelView];

    NSUInteger rowIndex = [column indexOfObject:jewelView];

    if (rowIndex == 0) {
        return nil;
    }

    JewelView *belowJewel = column[rowIndex - 1];

    return belowJewel;
}

@end