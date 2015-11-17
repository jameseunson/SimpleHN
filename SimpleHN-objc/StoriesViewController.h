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
#import "StoriesCommentsBaseViewController.h"

@class StoryDetailViewController;

@interface StoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, StoryCellDelegate>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) Firebase * ref;

@property (strong, nonatomic) StoryDetailViewController *detailViewController;
@property (nonatomic, strong) NSMutableArray * storiesList;

@property (nonatomic, strong) NSProgress * loadingProgress;

- (void)loadStoryIdentifiersWithRef:(Firebase *)ref;
- (void)loadVisibleStories;

@end

