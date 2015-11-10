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
    Firebase * newStoriesRef = [[Firebase alloc] initWithUrl:
                                        @"https://hacker-news.firebaseio.com/v0/newstories"];
    [self loadStoryIdentifiersWithRef:newStoriesRef];
}


@end
