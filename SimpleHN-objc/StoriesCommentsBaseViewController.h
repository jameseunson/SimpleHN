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

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kStoryLoadMoreCellReuseIdentifier @"storyLoadMoreCellReuseIdentifier"
#define kCommentCellReuseIdentifier @"kCommentCellReuseIdentifier"

// Enables sharing of login for pull-to-load more functionality
// between all controllers that use it

@class StoriesCommentsSearchResultsViewController;
@protocol StoriesCommentsSearchResultsViewControllerDelegate;

@interface StoriesCommentsBaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
    StoryCellDelegate, CommentCellDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate,
    StoriesCommentsSearchResultsViewControllerDelegate, StoryCommentVotingTableViewCellDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) ContentLoadingView * loadingView;

@property (nonatomic, assign) NSInteger currentVisibleItemMax;

@property (nonatomic, strong) NSMutableDictionary < NSNumber *, NSNumber * > * itemsLoadStatus;
@property (nonatomic, strong) NSMutableDictionary < NSNumber *, id > * itemsLookup;

@property (nonatomic, strong) NSMutableArray < NSNumber * > * visibleItems;

//@property (nonatomic, strong) NSIndexPath * expandedCellIndexPath;

@property (nonatomic, assign) BOOL shouldDisplayLoadMoreCell;

@property (nonatomic, assign) CGFloat loadMoreStartYPosition;
@property (nonatomic, assign) CGFloat loadMoreCompleteYPosition;
@property (nonatomic, assign) CGFloat lastContentOffset;

@property (nonatomic, assign) BOOL loadMoreOnReleasePending;

@property (nonatomic, strong) NSProgress * loadingProgress;

@property (nonatomic, strong) UISearchController * searchController;
@property (nonatomic, strong) StoriesCommentsSearchResultsViewController * searchResultsController;
@property (nonatomic, strong) UITableView * recentQueriesTableView;

@property (nonatomic, assign) BOOL pendingSearchOperation;
@property (nonatomic, strong) NSString * pendingSearchQuery;
@property (nonatomic, strong) NSString * activeQuery;

- (id)itemForIndexPath:(NSIndexPath *)indexPath;
- (void)loadMoreItems;

- (void)query:(NSString*)query;

@end
