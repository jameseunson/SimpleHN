//
//  AskHNViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "AskHNViewController.h"

@implementation AskHNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Ask";
    self.storyType = StoryTypeAskHN;
    
    self.ref = [[Firebase alloc] initWithUrl:
                                @"https://hacker-news.firebaseio.com/v0/askstories"];
//    [self loadStoryIdentifiersWithRef:self.ref];
    [self loadContent:nil];
}

#pragma mark - StoriesTimePeriodSelectViewController Methods
- (void)storiesTimePeriodSelectViewController:(StoriesTimePeriodSelectViewController*)controller
                  didChangeSelectedTimePeriod:(NSNumber*)period {
    
    [super storiesTimePeriodSelectViewController:controller didChangeSelectedTimePeriod:period];
    
    [[HNAlgoliaAPIManager sharedManager] loadTopStoriesWithTimePeriod:[period intValue] page:0 type:StoriesPageTypeAskHN completion:^(NSDictionary *result) {
        if(!result || ![[result allKeys] containsObject:kHNAlgoliaAPIManagerResults] || [result[kHNAlgoliaAPIManagerResults] count] == 0) {
            [self createErrorAlertWithTitle:@"Error" message:@"Unable to load stories for specified time period. Please check your connection and try again later."];
            return;
        }
        [self.selectedTimePeriodStories addObjectsFromArray:result[kHNAlgoliaAPIManagerResults]];
        [self.tableView reloadData];
        self.initialLoadDone = YES;
    }];
}

@end
