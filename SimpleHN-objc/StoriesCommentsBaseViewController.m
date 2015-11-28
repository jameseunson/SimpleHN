//
//  StoriesCommentsBaseViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsBaseViewController.h"
#import "StoriesCommentsSearchResultsViewController.h"
#import "SuProgress.h"

@import SafariServices;

@interface StoriesCommentsBaseViewController ()
- (void)didToggleNightMode:(id)sender;
@end

@implementation StoriesCommentsBaseViewController

- (void)awakeFromNib {
    
    _currentVisibleItemMax = 20;
    _shouldDisplayLoadMoreCell = NO;
    
    _loadMoreStartYPosition = -1;
    _loadMoreCompleteYPosition = -1;
    _lastContentOffset = -1;
    _loadMoreOnReleasePending = NO;
    
    self.visibleItems = [[NSMutableArray alloc] init];
    
    self.itemsLoadStatus = [[NSMutableDictionary alloc] init];
    self.itemsLookup = [[NSMutableDictionary alloc] init];
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:
                      CGRectZero style:UITableViewStylePlain];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[StoryCell class]
           forCellReuseIdentifier:kStoryCellReuseIdentifier];
    [self.tableView registerClass:[StoryLoadMoreCell class]
           forCellReuseIdentifier:kStoryLoadMoreCellReuseIdentifier];
    [self.tableView registerClass:[CommentCell class]
           forCellReuseIdentifier:kCommentCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Disable content inset on simulator, where it doesn't work
    // for some unknown reason
//    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height +
//                                                   [UIApplication sharedApplication].statusBarFrame.size.height, 0,
//                                                   self.tabBarController.tabBar.frame.size.height, 0);
    
    [self.view addSubview:_tableView];
    
    self.loadingView = [[ContentLoadingView alloc] init];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_loadingView];
    
    self.searchResultsController = [[StoriesCommentsSearchResultsViewController alloc] init];
    _searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
//    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
//    self.searchController.searchBar.tintColor = RGBCOLOR(243, 243, 243);
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_loadingView, _tableView);
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_loadingView]|;V:|[_loadingView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_tableView]|;V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    
    UITapGestureRecognizer * nightModeTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self action:@selector(didToggleNightMode:)];
    nightModeTapGestureRecognizer.numberOfTapsRequired = 2;
    nightModeTapGestureRecognizer.numberOfTouchesRequired = 2;
    
    [self.navigationController.navigationBar
     addGestureRecognizer:nightModeTapGestureRecognizer];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SuProgressForProgress:((AppDelegate *)[[UIApplication sharedApplication]
                                                 delegate]).masterProgress];
}

// Stub method, to be overridden in subclass
- (void)loadMoreItems {
    NSLog(@"StoriesCommentsBaseViewController, loadMoreItems called");
    
    // Reset to original state
    StoryLoadMoreCell * loadMoreCell = [self.tableView cellForRowAtIndexPath:
                                        [NSIndexPath indexPathForRow:self.currentVisibleItemMax inSection:0]];
    loadMoreCell.state = StoryLoadMoreCellStateNormal;
}

- (void)query:(NSString*)query {
    
    NSLog(@"query: %@", query);
    
    [[HNAlgoliaAPIManager sharedManager] query:query withCompletion:^(NSDictionary *result) {
        NSLog(@"StoriesCommentsBaseViewController, HNAlgoliaAPIManager query, result: %@", result);

        if(!result) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Unable to contact the search server. Please try again later."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            
            NSArray * results = result[kHNAlgoliaAPIManagerResults];
            [_searchResultsController addSearchResults:results];
        }
    }];
    
//    https://hn.algolia.com/api
//    http://hn.algolia.com/api/v1/search?query=foo&tags=story
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //    NSInteger itemsCount = MIN(_currentVisibleStoryMax, [self.user.submitted count]);
    //    if(itemsCount > 0) {
    //        itemsCount = itemsCount + 1;
    //    }
    //    return itemsCount;
    
    NSInteger itemsCount = [_visibleItems count];
    if(itemsCount > 0 && _shouldDisplayLoadMoreCell) {
        itemsCount = itemsCount + 1;
    }
    return itemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
            
            if(_expandedCellIndexPath && [indexPath isEqual:_expandedCellIndexPath]) {
                cell.expanded = YES;
                
            } else {
                cell.expanded = NO;
            }
            
            cell.delegate = self;
            return cell;
            
        } else {
            
            CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier
                                                                 forIndexPath:indexPath];
            cell.comment = item;
            if(_expandedCellIndexPath && [indexPath isEqual:_expandedCellIndexPath]) {
                cell.expanded = YES;
                
            } else {
                cell.expanded = NO;
            }
            
            cell.delegate = self;
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == self.currentVisibleItemMax) {
        _loadMoreStartYPosition = cell.frame.origin.y;
        _loadMoreCompleteYPosition = cell.frame.origin.y + cell.frame.size.height;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if(indexPath.row == self.currentVisibleItemMax) {
        _loadMoreStartYPosition = -1;
        _loadMoreCompleteYPosition = -1;
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
                                            [NSIndexPath indexPathForRow:self.currentVisibleItemMax inSection:0]];
        
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
        
        Story * story = [self itemForIndexPath:
                         [self.tableView indexPathForSelectedRow]];
        
        StoryDetailViewController *controller = (StoryDetailViewController *)
        [[segue destinationViewController] topViewController];
        [controller setDetailItem:story];
        
        controller.navigationItem.leftBarButtonItem =
        self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Property Override Methods
- (void)setShouldDisplayLoadMoreCell:(BOOL)shouldDisplayLoadMoreCell {
    _shouldDisplayLoadMoreCell = shouldDisplayLoadMoreCell;
    
    [self.tableView reloadData];
}

#pragma mark - StoryCellDelegate Methods
- (void)storyCellDidDisplayActionDrawer:(StoryCell*)cell {
    NSLog(@"storyCellDidDisplayActionDrawer:");
    
    if(_expandedCellIndexPath) {
        StoryCell * expandedCell = [self.tableView cellForRowAtIndexPath:
                                    _expandedCellIndexPath];
        expandedCell.expanded = NO;
    }
    
    self.expandedCellIndexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
- (void)storyCell:(StoryCell*)cell didTapActionWithType:(NSNumber*)type {
    [StoryCell handleActionForStory:cell.story withType:type inController:self];
}

#pragma mark - CommentCellDelegate Methods
- (void)commentCell:(CommentCell*)cell didTapLink:(NSURL*)link {
    SFSafariViewController * controller = [[SFSafariViewController alloc]
                                           initWithURL:link];
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)commentCell:(CommentCell*)cell didTapActionWithType:(NSNumber*)type {
    [CommentCell handleActionForComment:cell.comment withType:type inController:self];
}

#pragma mark - UISearchResultsUpdating Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    UISearchBar * searchBar = _searchController.searchBar;
    NSString * query = searchBar.text;
    
    NSLog(@"updateSearchResultsForSearchController: %@", query);
    
    if([query isEqualToString:self.activeQuery]) {
        NSLog(@"query is already activeQuery, returning early");
        return;
    }
    
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

#pragma mark - StoriesCommentsSearchResultsViewControllerDelegate <NSObject>
- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)controller didSelectResult:(id)result {
    NSLog(@"storiesCommentsSearchResultsViewController:didSelectResult:");
}

#pragma mark - Private Methods
- (void)didToggleNightMode:(id)sender {
    NSLog(@"didToggleNightMode:");
}

@end
