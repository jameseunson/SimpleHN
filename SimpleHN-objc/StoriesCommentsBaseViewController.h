//
//  StoriesCommentsBaseViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 17/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentLoadingView.h"
#import "StoryLoadMoreCell.h"
#import "StoryCell.h"
#import "CommentCell.h"
#import "StoryCommentsContentLoadingCell.h"
#import "ProgressBarView.h"
#import "SimpleHNNightModeViewController.h"

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kStoryLoadMoreCellReuseIdentifier @"storyLoadMoreCellReuseIdentifier"
#define kCommentCellReuseIdentifier @"commentCellReuseIdentifier"
#define kStoryCommentsContentLoadingCellReuseIdentifier @"storyCommentsContentLoadingCellReuseIdentifier"

@interface StoriesCommentsBaseViewController : SimpleHNNightModeViewController <StoryCellDelegate, CommentCellDelegate, StoryCommentVotingTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UITableViewController * tableViewController;

@property (nonatomic, assign) BOOL initialLoadDone;
@property (nonatomic, strong) NSDateFormatter * refreshDateFormatter;

@property (nonatomic, assign) NSInteger currentVisibleItemMax;

@property (nonatomic, strong) NSMutableDictionary < NSNumber *, NSNumber * > * itemsLoadStatus;
@property (nonatomic, strong) NSMutableDictionary < NSNumber *, id > * itemsLookup;

@property (nonatomic, strong) NSMutableArray < NSNumber * > * visibleItems;

@property (nonatomic, assign) BOOL shouldDisplayLoadMoreCell;

@property (nonatomic, assign) CGFloat loadMoreStartYPosition;
@property (nonatomic, assign) CGFloat loadMoreCompleteYPosition;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) NSInteger loadMoreRowIndex;

@property (nonatomic, assign) BOOL loadMoreOnReleasePending;
@property (nonatomic, strong) NSProgress * loadingProgress;

//- (void)updateNightMode;
- (id)itemForIndexPath:(NSIndexPath *)indexPath;

- (void)loadContent:(id)sender;
- (void)loadMoreItems;

@end
