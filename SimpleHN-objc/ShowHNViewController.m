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
    
    self.ref = [[Firebase alloc] initWithUrl:
                                @"https://hacker-news.firebaseio.com/v0/showstories"];
//    [self loadStoryIdentifiersWithRef:self.ref];
    [self loadContent:nil];    
}

@end
