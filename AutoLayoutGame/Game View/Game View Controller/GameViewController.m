//
// Created by Oliver Foggin on 17/05/2013.
// Copyright (c) 2013 Oliver Foggin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "GameViewController.h"
#import "JewelGridView.h"

@interface GameViewController ()

@property (nonatomic, weak) IBOutlet JewelGridView *jewelGridView;

@end

@implementation GameViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.jewelGridView replaceMissingJewels];
}

@end