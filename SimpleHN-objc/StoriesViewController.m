//
//  MasterViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesViewController.h"
#import "StoryDetailViewController.h"
#import "Story.h"
#import "StoryLoadMoreCell.h"
#import "UserViewController.h"
#import "SuProgress.h"

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kStoryLoadMoreCellReuseIdentifier @"storyLoadMoreCellReuseIdentifier"

@interface StoriesViewController ()

@property (nonatomic, strong) NSMutableDictionary * storiesLoadStatus;
@property (nonatomic, strong) NSMutableDictionary * storiesLookup;

@property (nonatomic, strong) NSMutableDictionary * storyDiffLookup;

//@property (nonatomic, assign) NSInteger currentVisibleStoryMin;
@property (nonatomic, assign) NSInteger currentVisibleStoryMax;

@property (nonatomic, strong) UIRefreshControl * bottomRefreshControl;

@property (nonatomic, strong) NSIndexPath * expandedCellIndexPath;

- (void)reloadContent:(id)sender;
- (void)loadMoreStories:(id)sender;

- (Story*)storyForIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)indexPathForStory:(Story*)story;

@end

@implementation StoriesViewController

- (void)dealloc {
    if(self.ref) {
        [self.ref removeAllObservers];
    }
}

- (void)awakeFromNib {
    
    _currentVisibleStoryMax = 20;
    
    self.storiesList = [[NSMutableArray alloc] init];
    self.storiesLoadStatus = [[NSMutableDictionary alloc] init];
    self.storiesLookup = [[NSMutableDictionary alloc] init];
    
    // Transient storage so the cellForRow method can pickup a pending
    // diff to associate with a story that has been updated by Firebase
    self.storyDiffLookup = [[NSMutableDictionary alloc] init];
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:21];
}

- (void)loadView {
    [super loadView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[StoryCell class]
           forCellReuseIdentifier:kStoryCellReuseIdentifier];
    [self.tableView registerClass:[StoryLoadMoreCell class]
           forCellReuseIdentifier:kStoryLoadMoreCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
//    // Initialize the refresh control.
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.backgroundColor = RGBCOLOR(235, 235, 235);
//    self.refreshControl.tintColor = [UIColor grayColor];
//    
//    [self.refreshControl addTarget:self
//                            action:@selector(reloadContent:)
//                  forControlEvents:UIControlEventValueChanged];
    
    [self SuProgressForProgress:self.loadingProgress];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = ((SimpleHNSplitViewController*)
                                 self.splitViewController).storyDetailViewController;
//    [self.refreshControl beginRefreshing];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        Story * story = [self storyForIndexPath:[self.tableView indexPathForSelectedRow]];
        
        StoryDetailViewController *controller = (StoryDetailViewController *)
            [[segue destinationViewController] topViewController];
        [controller setDetailItem:story];
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    } else if([[segue identifier] isEqualToString:@"showUser"]) {
        NSLog(@"prepareForSegue, showUser");
        
        Story * story = [self storyForIndexPath:[self.tableView indexPathForSelectedRow]];
        
        __block UserViewController *controller = (UserViewController *)
            [[segue destinationViewController] topViewController];
        
        [story loadUserForStory:^(User *user) {
            [controller setUser:user];
        }];
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.tableView) {
        if(scrollView.contentOffset.y > (scrollView.contentSize.height - 44.0f)) {
            [_bottomRefreshControl beginRefreshing];
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger itemsCount = MIN(_currentVisibleStoryMax, [self.storiesList count]);
    if(itemsCount > 0) {
        itemsCount = itemsCount + 1;
    }
    return itemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == _currentVisibleStoryMax && [self.storiesList count] > 0) {
        
        StoryLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                           kStoryLoadMoreCellReuseIdentifier forIndexPath:indexPath];
        return cell;
        
    } else {
        
        StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                           kStoryCellReuseIdentifier forIndexPath:indexPath];
        cell.story = [self storyForIndexPath:indexPath];
        
        if(_expandedCellIndexPath && [indexPath isEqual:_expandedCellIndexPath]) {
            cell.expanded = YES;
            
        } else {
            cell.expanded = NO;
        }
        
        cell.delegate = self;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == _currentVisibleStoryMax && [self.storiesList count] > 0) {
        [self loadMoreStories:nil];
        
    } else {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    }
}

- (void)reloadContent:(id)sender {
    
    // Simulated reload, TODO: Real reload
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Private Methods
- (void)loadStoryIdentifiersWithRef:(Firebase *)ref {
    
//    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"FEventTypeChildAdded: %@", snapshot);
//    }];
//    [ref observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"FEventTypeChildChanged: %@", snapshot);
//        
//        // We use the 'loaded' status of the story as a proxy
//        // for whether it is visible or not. If it isn't visible,
//        // there's no need to waste resources on reloading it
//        NSNumber * identifier = snapshot.value;
//        if(![_storiesLoadStatus[identifier] isEqual:@(StoryLoadStatusLoaded)]) {
//            NSLog(@"skipping story with identifier: %@, it's not visible/loaded", identifier);
//            return;
//        }
//        
//        NSLog(@"reloading changed story with identifier: %@", identifier);
//        
//        __block Story * previousStory = _storiesLookup[identifier];
//        
//        [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {
//            
//            NSDictionary * diff = [previousStory diffOtherStory:story];
//            if([[diff allKeys] count] == 0) {
//                NSLog(@"No difference, no reason to update table, returning early");
//                return;
//            }
//            
//            _storiesLookup[identifier] = story;
//            _storiesLoadStatus[identifier] = @(StoryLoadStatusLoaded);
//            
//            NSLog(@"diff: %@", diff);
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"updating tableview for story with identifier: %@", identifier);
//                
//                NSIndexPath * reloadIndexPath = [self indexPathForStory:story];
//                if(reloadIndexPath) {
//                    [self.tableView beginUpdates];
//                    [self.tableView reloadRowsAtIndexPaths:@[ reloadIndexPath ]
//                                          withRowAnimation:UITableViewRowAnimationAutomatic];
//                    [self.tableView endUpdates];
//                    NSLog(@"done updating tableview for story with identifier: %@", identifier);
//                }
//            });
//        }];
//    }];
    [ref observeEventType:FEventTypeChildMoved withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"FEventTypeChildMoved: %@", snapshot);
    }];
//    [ref observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"FEventTypeChildRemoved: %@", snapshot);
//    }];
    
    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.storiesList addObjectsFromArray:snapshot.value];
        self.loadingProgress.completedUnitCount++;
        
        [self loadVisibleStories];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

- (void)loadVisibleStories {
    
    int i = 0;
    for(NSNumber * identifier in _storiesList) {
        
        if([_storiesLoadStatus[identifier] isEqual:@(StoryLoadStatusLoading)] ||
           [_storiesLoadStatus[identifier] isEqual:@(StoryLoadStatusLoaded)]) {
            i++; continue;
            
        } else {
         
            _storiesLoadStatus[identifier] = @(StoryLoadStatusNotLoaded);
            
            if(i < _currentVisibleStoryMax) {
                _storiesLoadStatus[identifier] = @(StoryLoadStatusLoading);
                [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {
                    
                    _storiesLookup[identifier] = story;
                    _storiesLoadStatus[identifier] = @(StoryLoadStatusLoaded);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.loadingProgress.completedUnitCount++;
                        [self.tableView reloadData];
                    });
                }];
            }
        }
        i++;
    }
    
}
- (void)loadMoreStories:(id)sender {
    NSLog(@"loadMoreStories:");
    
    self.currentVisibleStoryMax += 20;
    [self loadVisibleStories];
}

- (Story*)storyForIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *storyIdentifier = self.storiesList[indexPath.row];
    if([[_storiesLookup allKeys] containsObject:storyIdentifier]) {
        return _storiesLookup[storyIdentifier];
    } else {
        return nil;
    }
}

- (NSIndexPath*)indexPathForStory:(Story*)story {
    if([[_storiesLookup allKeys] containsObject:story.storyId]) {
        NSInteger loc = [_storiesList indexOfObject:story.storyId];
        if(loc != NSNotFound) {
            return [NSIndexPath indexPathForRow:loc inSection:0];
        }
    }
    return nil;
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
    ActionDrawerViewButtonType actionType = [type intValue];
    
    if(actionType == ActionDrawerViewButtonTypeUser) {
        NSLog(@"StoryActionDrawerViewButtonTypeUser");
        
        [cell.story loadUserForStory:^(User *user) {
            [self performSegueWithIdentifier:@"showUser" sender:user];
        }];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        
        UIAlertController * controller = [UIAlertController alertControllerWithTitle:cell.story.title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [controller addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end
