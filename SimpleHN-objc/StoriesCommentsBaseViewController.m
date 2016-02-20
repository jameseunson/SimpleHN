//
//  StoriesCommentsBaseViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsBaseViewController.h"
#import "StoriesCommentsSearchResultsViewController.h"
//#import "SuProgress.h"
#import "SimpleHNWebViewController.h"

//@import SafariServices;

@interface StoriesCommentsBaseViewController ()

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

- (void)processAlgoliaSearchResult:(NSDictionary*)result;

@property (nonatomic, strong) UIColor * defaultSeparatorColor;

@end

@implementation StoriesCommentsBaseViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    
    _initialLoadDone = NO;
    _currentVisibleItemMax = 20;
    _shouldDisplayLoadMoreCell = NO;
    
    _loadMoreStartYPosition = -1;
    _loadMoreCompleteYPosition = -1;
    _lastContentOffset = -1;
    _loadMoreOnReleasePending = NO;
    
    self.visibleItems = [[NSMutableArray alloc] init];
    
    self.itemsLoadStatus = [[NSMutableDictionary alloc] init];
    self.itemsLookup = [[NSMutableDictionary alloc] init];
    
    self.refreshDateFormatter = [[NSDateFormatter alloc] init];
    [_refreshDateFormatter setDateFormat:@"MMM d, h:mm a"];
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    _refreshDateFormatter.locale = locale;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionNightFallingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionDawnComingNotification object:nil];
}

- (void)loadView {
    [super loadView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[StoryCell class]
           forCellReuseIdentifier:kStoryCellReuseIdentifier];
    [self.tableView registerClass:[StoryLoadMoreCell class]
           forCellReuseIdentifier:kStoryLoadMoreCellReuseIdentifier];
    [self.tableView registerClass:[CommentCell class]
           forCellReuseIdentifier:kCommentCellReuseIdentifier];
    [self.tableView registerClass:[StoryCommentsContentLoadingCell class]
           forCellReuseIdentifier:kStoryCommentsContentLoadingCellReuseIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(loadContent:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.searchResultsController = [[StoriesCommentsSearchResultsViewController alloc] init];
    _searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    [self updateNightMode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if (self.navigationController && self.navigationController.navigationBar) {
//        UINavigationBar *navbar = self.navigationController.navigationBar;
//        NSArray * existingProgressBarViews = [[navbar subviews] filteredArrayUsingPredicate:
//                                              [NSPredicate predicateWithFormat:@"tag==%d", kProgressBarTag]];
//        if([existingProgressBarViews count] > 0) {
//            NSLog(@"Found existing progress bar");
//            self.progressBarView = [existingProgressBarViews firstObject];
//        } else {
//            self.progressBarView = [ProgressBarView addToNavBar:navbar];
//        }
//    }
    
    self.initialLoadDone = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    if (self.navigationController && self.navigationController.navigationBar) {
//        [ProgressBarView addToNavBar:self.navigationController.navigationBar];
//    }
}

// Stub method, to be overridden in subclass
- (void)loadMoreItems {
    NSLog(@"StoriesCommentsBaseViewController, loadMoreItems called");
    
    // Reset to original state
    StoryLoadMoreCell * loadMoreCell = [self.tableView cellForRowAtIndexPath:
                                        [NSIndexPath indexPathForRow:self.loadMoreRowIndex inSection:0]];
    loadMoreCell.state = StoryLoadMoreCellStateNormal;
}

- (void)query:(NSString*)query {
    [[HNAlgoliaAPIManager sharedManager] query:query withTimePeriod:[[AppConfig sharedConfig] activeSearchFilter]
                                      withPage:0 withCompletion:^(NSDictionary *result) {
        [self processAlgoliaSearchResult:result];
    }];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(_initialLoadDone) {
        NSInteger itemsCount = [_visibleItems count];
        if(itemsCount > 0 && _shouldDisplayLoadMoreCell) {
            itemsCount = itemsCount + 1;
        }
        return itemsCount;
        
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_initialLoadDone) {

        if(indexPath.row == [_visibleItems count] && [_visibleItems count] > 0
           && _shouldDisplayLoadMoreCell) {
            
            StoryLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                       kStoryLoadMoreCellReuseIdentifier forIndexPath:indexPath];
            return cell;
            
        } else {
            
            id item = [self itemForIndexPath:indexPath];
            if([item isKindOfClass:[Story class]]) {
                
                StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                   kStoryCellReuseIdentifier forIndexPath:indexPath];
                cell.story = item;
                
                cell.storyCellDelegate = self;
                cell.votingDelegate = self;
                
                return cell;
                
            } else {
                
                CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier
                                                                     forIndexPath:indexPath];
                cell.comment = item;
                
                cell.commentCellDelegate = self;
                
                return cell;
            }
        }
        
    } else {
        
        StoryCommentsContentLoadingCell * cell = [tableView dequeueReusableCellWithIdentifier:kStoryCommentsContentLoadingCellReuseIdentifier forIndexPath:indexPath];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == self.loadMoreRowIndex) {
        _loadMoreStartYPosition = cell.frame.origin.y;
        _loadMoreCompleteYPosition = cell.frame.origin.y + cell.frame.size.height;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if(indexPath.row == self.loadMoreRowIndex) {
        _loadMoreStartYPosition = -1;
        _loadMoreCompleteYPosition = -1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_initialLoadDone) {
        if(indexPath.row == self.loadMoreRowIndex || indexPath.row > self.loadMoreRowIndex) {
            return 60.0f;
            
        } else {
            
            @try {
                id item = [self itemForIndexPath:indexPath];
                if([item isKindOfClass:[Story class]]) {
                    return [StoryCell heightForStoryCellWithStory:item width:tableView.frame.size.width];
                    
                } else if([item isKindOfClass:[Comment class]]) {
                    return [CommentCell heightForCommentCell:item width:tableView.frame.size.width];
                    
                } else {
                    return 88.0f;
                }
            } @catch(NSException * e) {
                NSLog(@"heightForRowAtIndexPath: %@, crash", indexPath);
                return 44.0f;
            }
            
        }
        
    } else {
        return tableView.frame.size.height - tableView.contentInset.top - tableView.contentInset.bottom;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_initialLoadDone) {
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            cell.backgroundColor = UIColorFromRGB(0x222222);
            
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_initialLoadDone) {
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            cell.backgroundColor = kNightDefaultColor;
            
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.tableView) {
        
        // If there isn't more content to display, no reason to run any of this
        if(!_shouldDisplayLoadMoreCell) {
            return;
        }
        // If the loading cell has yet to appear on screen,
        // no reason to continue and waste resources
        if(_loadMoreStartYPosition == -1 || _loadMoreCompleteYPosition == -1) {
            return;
        }
        // If a load is currently in progress, ignore
        if(_loadingProgress.completedUnitCount != _loadingProgress.totalUnitCount) {
            return;
        }
        
        // contentOffset.y adjusted to match cell.frame.origin.y, taking into
        // account screen height and inset from navigation bar b/c of translucency
        CGFloat adjustedYPosition = (scrollView.contentOffset.y + scrollView.frame.size.height) -
        44.0f - self.tableView.contentInset.top;
        
        BOOL scrollingDown = NO;
        if(adjustedYPosition > _lastContentOffset) {
            scrollingDown = YES;
        }
        
        StoryLoadMoreCell * loadMoreCell = [self.tableView cellForRowAtIndexPath:
                                            [NSIndexPath indexPathForRow:self.loadMoreRowIndex inSection:0]];
        
        // Ensure that transition starts only when contentOffset is
        // within the 44pt size of the loading cell, and when the user
        // is scrolling down
        
        if( adjustedYPosition > _loadMoreStartYPosition &&
           adjustedYPosition < _loadMoreCompleteYPosition &&
           scrollingDown ) {
            
            if(loadMoreCell.state != StoryLoadMoreCellStateTransitionStart) {
                loadMoreCell.state = StoryLoadMoreCellStateTransitionStart;
            }
            
        } else if(adjustedYPosition > _loadMoreCompleteYPosition) {
            
            if(loadMoreCell.state != StoryLoadMoreCellStateTransitionComplete) {
                loadMoreCell.state = StoryLoadMoreCellStateTransitionComplete;
                
                _loadMoreOnReleasePending = YES;
            }
            
        } else {
            
            if(_loadMoreOnReleasePending) {
                
                [self loadMoreItems];
                loadMoreCell.state = StoryLoadMoreCellStateLoading;
                
                // Ensure the loading operation only occurs once
                // as scrollViewDidScroll is called frequently
                _loadMoreOnReleasePending = NO;
                
                // All these values are now no longer relevant
                // If left in place, loads will happen in the content y offset
                // the load cell was previously in, which is undesirable
                _loadMoreStartYPosition = -1;
                _loadMoreCompleteYPosition = -1;
                _lastContentOffset = -1;
                
            } else if(loadMoreCell.state != StoryLoadMoreCellStateNormal) {
                loadMoreCell.state = StoryLoadMoreCellStateNormal;
            }
        }
        
        _lastContentOffset = adjustedYPosition;
    }
}

- (id)itemForIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *identifier = _visibleItems[indexPath.row];
    if([[_itemsLookup allKeys] containsObject:identifier]) {
        return _itemsLookup[identifier];
    } else {
        return nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        StoryDetailViewController *controller = (StoryDetailViewController *)
        [[segue destinationViewController] topViewController];
        
        // Support for linking to item identifiers from comment cells
        if(sender && [sender isKindOfClass:[NSNumber class]]) {
            
            NSNumber * identifier = (NSNumber*)sender;
            
            // Check if item is a comment or story
            [HNItemHelper identifyHNItemWithNumber:identifier completion:^(HNItemHelperIdentificationResult identification) {
                
                if(identification == HNItemHelperIdentificationResultComment) {
                    
                    [Comment createCommentFromItemIdentifier:identifier completion:^(Comment *comment) {
                        controller.detailComment = comment;
                    }];
                    
                } else if(identification == HNItemHelperIdentificationResultStory ||
                          identification == HNItemHelperIdentificationResultUnknown) {
               
                    [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {
                        controller.detailItem = story;
                    }];
                }
                
            }];
            
        } else {
            
            Story * story = [self itemForIndexPath: [self.tableView indexPathForSelectedRow]];
            [controller setDetailItem:story];
        }
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    } else if([[segue identifier] isEqualToString:@"showWeb"]) {
        
        SimpleHNWebViewController *controller = (SimpleHNWebViewController *)
            [[segue destinationViewController] topViewController];
        
        if(sender && [sender isKindOfClass:[NSURL class]]) {
            controller.selectedURL = sender;
        }
    }
}

#pragma mark - Property Override Methods
- (void)setShouldDisplayLoadMoreCell:(BOOL)shouldDisplayLoadMoreCell {
    _shouldDisplayLoadMoreCell = shouldDisplayLoadMoreCell;
    
    [self.tableView reloadData];
}

- (void)setInitialLoadDone:(BOOL)initialLoadDone {
    _initialLoadDone = initialLoadDone;
    
    if(_initialLoadDone) {
        self.tableView.scrollEnabled = YES;
        
    } else {
        self.tableView.scrollEnabled = NO;
    }
}

- (NSInteger)loadMoreRowIndex {
    return self.currentVisibleItemMax;
}

#pragma mark - StoryCellDelegate Methods
- (void)storyCell:(StoryCell*)cell didTapActionWithType:(NSNumber*)type {
    [StoryCell handleActionForStory:cell.story withType:type inController:self];
}

- (void)storyCellDidTapCommentsArea:(StoryCell*)cell {
    [self performSegueWithIdentifier:@"showDetail" sender:cell.story];
}

#pragma mark - CommentCellDelegate Methods
- (void)commentCell:(CommentCell*)cell didTapLink:(NSURL*)link {
    
    if([link isHNInternalLink]) {
        
        if([link isHNInternalItemLink]) {
            NSNumber * identifier = [link identifierForHNInternalItemLink];
            if(identifier) {
                [self performSegueWithIdentifier:@"showDetail" sender:identifier]; return;
            }
            
        } else if([link isHNInternalUserLink]) {
            NSString * username = [link usernameForHNInternalUserLink];
            if(username) {
                [self performSegueWithIdentifier:@"showUser" sender:username]; return;
            }
        }
    } // Catches two else cases implicitly
    
    NSLog(@"%@", link);
    [self performSegueWithIdentifier:@"showWeb" sender:link];
}

- (void)commentCell:(CommentCell*)cell didLongPressLink:(NSURL *)link {
    NSLog(@"commentCell:didLongPressLink:");
    [CommentCell handleLongPressForLink:link inComment:cell.comment inController:self];    
}

- (void)commentCell:(CommentCell*)cell didTapActionWithType:(NSNumber*)type {
    [CommentCell handleActionForComment:cell.comment withType:type inController:self];
}

#pragma mark - UISearchResultsUpdating Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    UISearchBar * searchBar = _searchController.searchBar;
    NSString * query = searchBar.text;
    
    [self.searchResultsController clearAllResults];
    
    NSLog(@"updateSearchResultsForSearchController: %@", query);
    
    if([query isEqualToString:self.activeQuery]) {
        NSLog(@"query is already activeQuery, returning early");
        return;
    }
    self.activeQuery = query;
    
    if(_pendingSearchOperation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:
         self selector:@selector(query:) object:_pendingSearchQuery];
        
        _pendingSearchQuery = nil;
        _pendingSearchOperation = NO;
    }
    
    [self performSelector:@selector(query:) withObject:query afterDelay:0.5];
    
    _pendingSearchOperation = YES;
    _pendingSearchQuery = query;
}

#pragma mark - StoriesCommentsSearchResultsViewControllerDelegate
- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)controller didSelectResult:(id)result {
    NSLog(@"storiesCommentsSearchResultsViewController:didSelectResult:");
    
    if(self.splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        [self.searchController setActive:NO];
    }
    
    Story * story = (Story*)result;
    if(!story.url) { // Ask HN item, or Show HN item without a url
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController * nav = (UINavigationController *)
            [sb instantiateViewControllerWithIdentifier:@"StoryDetailViewControllerNavController"];
        StoryDetailViewController * vc = (StoryDetailViewController *)[nav topViewController];
        
        vc.detailItem = story;
        [self.splitViewController showDetailViewController:nav sender:nil];
        
    } else {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UINavigationController * nav = (UINavigationController *)
        [sb instantiateViewControllerWithIdentifier:@"SimpleHNWebViewControllerNavController"];
        SimpleHNWebViewController * vc = (SimpleHNWebViewController *)[nav topViewController];
        
        vc.selectedStory = story;
        [self.splitViewController showDetailViewController:nav sender:nil];
    }
}

- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
    controller didTapCommentsForResult:(id)result {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController * nav = (UINavigationController *)
    [sb instantiateViewControllerWithIdentifier:@"StoryDetailViewControllerNavController"];
    StoryDetailViewController * vc = (StoryDetailViewController *)[nav topViewController];
    
    vc.detailItem = result;
    [self.splitViewController showDetailViewController:nav sender:nil];
}

- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
    controller loadResultsForPageWithNumber:(NSNumber*)pageNumber {
    NSLog(@"storiesCommentsSearchResultsViewController:loadResultsForPageWithNumber: %@", pageNumber);
    
    NSString * query = self.activeQuery;
    [[HNAlgoliaAPIManager sharedManager] query:query withTimePeriod:[[AppConfig sharedConfig] activeSearchFilter]
                                      withPage:[pageNumber integerValue] withCompletion:^(NSDictionary *result) {
        [self processAlgoliaSearchResult:result];
    }];
}

- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
    controller didChangeTimePeriod:(NSNumber*)timePeriod {
    NSLog(@"storiesCommentsSearchResultsViewController:didChangeTimePeriod: %@", timePeriod);
    
    NSString * query = self.activeQuery;
    [[HNAlgoliaAPIManager sharedManager] query:query withTimePeriod:[[AppConfig sharedConfig] activeSearchFilter]
                                      withPage:0 withCompletion:^(NSDictionary *result) {
        [self processAlgoliaSearchResult:result];
    }];
}

#pragma mark - Private Methods

- (void)loadContent:(id)sender {
    NSLog(@"loadContent:");
}


- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}

- (void)updateNightMode {
    
    if(!_defaultSeparatorColor) {
        _defaultSeparatorColor = self.tableView.separatorColor;
    }
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        
        self.navigationController.navigationBar.barTintColor = kNightDefaultColor;
        self.tabBarController.tabBar.barTintColor = kNightDefaultColor;
        
        self.refreshControl.backgroundColor = kNightDefaultColor;
        self.view.backgroundColor = kNightDefaultColor;
        self.tableView.backgroundColor = kNightDefaultColor;
        
        self.tableView.separatorColor = UIColorFromRGB(0x555555);
        
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
        
        self.navigationController.navigationBar.titleTextAttributes =
            @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
        
    } else {
        
        self.navigationController.navigationBar.barTintColor = nil;
        self.tabBarController.tabBar.barTintColor = nil;
        
        self.refreshControl.backgroundColor = UIColorFromRGB(0xffffff);
        self.view.backgroundColor = UIColorFromRGB(0xffffff);
        self.tableView.backgroundColor = UIColorFromRGB(0xffffff);
        
        self.tableView.separatorColor = _defaultSeparatorColor;
        
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor blackColor]];
        
        self.navigationController.navigationBar.titleTextAttributes =
            @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    }
    
    [self.tableView reloadData];
}

- (void)processAlgoliaSearchResult:(NSDictionary*)result {
    
    if(!result) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Unable to contact the search server. Please try again later."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        if([[result allKeys] containsObject:kHNAlgoliaAPIManagerTotalHits]) {
            _searchResultsController.totalResultsCount = [result[kHNAlgoliaAPIManagerTotalHits] integerValue];
        }
        if([[result allKeys] containsObject:kHNAlgoliaAPIManagerCurrentPage]) {
            _searchResultsController.currentPage = [result[kHNAlgoliaAPIManagerCurrentPage] integerValue];
        }
        NSArray * results = result[kHNAlgoliaAPIManagerResults];
        [_searchResultsController addSearchResults:results];
    }
}

#pragma mark - StoryCommentVotingTableViewCellDelegate Methods
- (void)storyCommentCellDidUpvote:(StoryCommentBaseTableViewCell*)cell {
    
}

- (void)storyCommentCellDidDownvote:(StoryCommentBaseTableViewCell*)cell {
    
}

@end
