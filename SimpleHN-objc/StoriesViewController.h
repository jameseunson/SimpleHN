//
//  MasterViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firebase.h"
#import "StoryCell.h"

@class StoryDetailViewController;

@interface StoriesViewController : UITableViewController <UIScrollViewDelegate, StoryCellDelegate>

@property (strong, nonatomic) StoryDetailViewController *detailViewController;
@property (nonatomic, strong) NSMutableArray * storiesList;

@property (nonatomic, strong) NSProgress * loadingProgress;

- (void)loadStoryIdentifiersWithRef:(Firebase *)ref;
- (void)loadVisibleStories;

@end

