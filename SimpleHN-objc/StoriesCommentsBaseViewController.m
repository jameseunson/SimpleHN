//
//  StoriesCommentsBaseViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsBaseViewController.h"
#import "SimpleHNWebViewController.h"

@interface StoriesCommentsBaseViewController ()

- (void)didTapSearchItem:(id)sender;

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
    
    self.tableViewController = [[UITableViewController alloc]
                                initWithStyle:UITableViewStylePlain];
}

- (void)loadView {
    [super loadView];
    
    self.tableView = _tableViewController.tableView;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
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

    self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
    self.tableViewController.refreshControl.backgroundColor = [UIColor whiteColor];
    self.tableViewController.refreshControl.tintColor = [UIColor grayColor];
    [self.tableViewController.refreshControl addTarget:self
                            action:@selector(loadContent:)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_tableView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView);
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_tableView]|;V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self updateNightMode];
    
    _tableViewController.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height +
                                                              [UIApplication sharedApplication].statusBarFrame.size.height,
                                                                   
                                                              0, self.tabBarController.tabBar.frame.size.height +
                                                                   self.navigationController.toolbar.frame.size.height, 0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.initialLoadDone = NO;
    
    NSMutableArray * rightItemsMutable = [self.navigationItem.rightBarButtonItems mutableCopy];
    
    UIBarButtonItem * searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search-toolbar"]
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(didTapSearchItem:)];
    [rightItemsMutable addObject:searchItem];
    self.navigationItem.rightBarButtonItems = rightItemsMutable;
}

// Stub method, to be overridden in subclass
- (void)loadMoreItems {
    
    // Reset to original state
    StoryLoadMoreCell * loadMoreCell = [self.tableView cellForRowAtIndexPath:
                                        [NSIndexPath indexPathForRow:self.loadMoreRowIndex inSection:0]];
    loadMoreCell.state = StoryLoadMoreCellStateNormal;
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
                NSLog(@"ERROR: heightForRowAtIndexPath: %@, crash", indexPath);
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
    [self performSegueWithIdentifier:@"showWeb" sender:link];
}

- (void)commentCell:(CommentCell*)cell didLongPressLink:(NSURL *)link {
    [CommentCell handleLongPressForLink:link inComment:cell.comment inController:self];    
}

- (void)commentCell:(CommentCell*)cell didTapActionWithType:(NSNumber*)type {
    [CommentCell handleActionForComment:cell.comment withType:type inController:self];
}

#pragma mark - Private Methods

- (void)loadContent:(id)sender {
}

- (void)updateNightMode {
    [super updateNightMode];
    
    if(!self.defaultSeparatorColor) {
        self.defaultSeparatorColor = self.tableView.separatorColor;
    }
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        
        self.tableViewController.refreshControl.backgroundColor = kNightDefaultColor;
        self.tableView.backgroundColor = kNightDefaultColor;
        self.tableView.separatorColor = UIColorFromRGB(0x555555);
        
    } else {
        
        self.tableViewController.refreshControl.backgroundColor = UIColorFromRGB(0xffffff);
        self.tableView.backgroundColor = UIColorFromRGB(0xffffff);
        self.tableView.separatorColor = self.defaultSeparatorColor;
    }
    
    [self.tableView reloadData];
}

- (void)didTapSearchItem:(id)sender {
    [self performSegueWithIdentifier:@"showSearch" sender:nil];
}

#pragma mark - StoryCommentVotingTableViewCellDelegate Methods
- (void)storyCommentCellDidVote:(StoryCommentBaseTableViewCell*)cell
                       voteType:(NSNumber*)voteType {
    NSLog(@"storyCommentCellDidVote: %@", voteType);
}

@end
