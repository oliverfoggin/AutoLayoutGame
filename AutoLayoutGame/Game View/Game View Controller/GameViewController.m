//
// Created by Oliver Foggin on 17/05/2013.
// Copyright (c) 2013 Oliver Foggin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "GameViewController.h"
#import "JewelGridView.h"

@interface GameViewController () <JewelGridDelegate>

@property (nonatomic, weak) IBOutlet JewelGridView *jewelGridView;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;

@property (nonatomic) NSInteger score;

@end

@implementation GameViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.score = 0;

    [self.jewelGridView replaceMissingJewels];
    self.jewelGridView.delegate = self;
}

- (void)setScore:(NSInteger)score
{
    _score = score;

    self.scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
}

- (void)removedJewels:(NSUInteger)numberOfJewelsRemoved
{
    self.score += (int)powf(2, numberOfJewelsRemoved);
}

@end