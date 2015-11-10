//
//  ShowHNViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "ShowHNViewController.h"

@implementation ShowHNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Show";
    
    Firebase * showStoriesRef = [[Firebase alloc] initWithUrl:
                                @"https://hacker-news.firebaseio.com/v0/showstories"];
    [self loadStoryIdentifiersWithRef:showStoriesRef];
}

@end
