//
//  TopStoriesViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "TopStoriesViewController.h"

@implementation TopStoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Top";
    
    Firebase * topStoriesRef = [[Firebase alloc] initWithUrl:
                                        @"https://hacker-news.firebaseio.com/v0/topstories"];
    [self loadStoryIdentifiersWithRef:topStoriesRef];
}

@end
