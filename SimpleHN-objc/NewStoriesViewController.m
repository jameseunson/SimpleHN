//
//  NewStoriesViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "NewStoriesViewController.h"

@implementation NewStoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"New";
    
    // Remove time period selector - this is 'new' stories, so not relevant
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!self.ref) {
        self.ref = [[Firebase alloc] initWithUrl:
                    @"https://hacker-news.firebaseio.com/v0/newstories"];
        [self loadContent:nil];
    }
}

@end
