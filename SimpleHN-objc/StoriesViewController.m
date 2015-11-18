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
#import "ContentLoadingView.h"

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kStoryLoadMoreCellReuseIdentifier @"storyLoadMoreCellReuseIdentifier"

@interface StoriesViewController ()

- (void)loadVisibleItems;

@property (nonatomic, strong) NSMutableArray < NSNumber * > * storiesList;
@property (nonatomic, strong) NSMutableDictionary * storyDiffLookup;

@end

@implementation StoriesViewController

- (void)dealloc {
    if(self.ref) {
        [self.ref removeAllObservers];
    }
    [self.loadingProgress removeObserver:self
                          forKeyPath:@"fractionCompleted"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Transient storage so the cellForRow method can pickup a pending
    // diff to associate with a story that has been updated by Firebase
    self.storyDiffLookup = [[NSMutableDictionary alloc] init];
    
    self.storiesList = [[NSMutableArray alloc] init];
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:21];
    [self.loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                          options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)loadView {
    [super loadView];
    
    [self SuProgressForProgress:self.loadingProgress];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = ((SimpleHNSplitViewController*)
                                 self.splitViewController).storyDetailViewController;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        Story * story = [self itemForIndexPath:[self.tableView indexPathForSelectedRow]];
        
        StoryDetailViewController *controller = (StoryDetailViewController *)
            [[segue destinationViewController] topViewController];
        [controller setDetailItem:story];
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    } else if([[segue identifier] isEqualToString:@"showUser"]) {
        NSLog(@"prepareForSegue, showUser");
        
        Story * story = [self itemForIndexPath:[self.tableView indexPathForSelectedRow]];
        
        __block UserViewController *controller = (UserViewController *)
            [[segue destinationViewController] topViewController];
        
        if(sender && [sender isKindOfClass:[NSString class]]) {
            controller.author = sender;
        } else {
            controller.author = story.author;
        }
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == self.currentVisibleItemMax && [self.storiesList count] > 0) {
        [self loadMoreItems];
        
    } else {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    }
}

- (void)reloadContent:(id)sender {
    
    // Simulated reload, TODO: Real reload
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.refreshControl endRefreshing];
//    });
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
        
        [self loadVisibleItems];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

- (void)loadVisibleItems {
    
    if([self.storiesList count] > self.currentVisibleItemMax) {
        self.shouldDisplayLoadMoreCell = YES;
    } else {
        self.shouldDisplayLoadMoreCell = NO;
    }
    
    [self.visibleItems removeAllObjects];
    
    NSArray * loadedItems = [self.storiesList subarrayWithRange:
                             NSMakeRange(0, MIN(self.currentVisibleItemMax, [self.storiesList count]))];
    [self.visibleItems addObjectsFromArray:loadedItems];
    
    // Ensure that if the user has < 20 submissions,
    // the page isn't endlessly stuck loading
    self.loadingProgress.completedUnitCount = 0;
    self.loadingProgress.totalUnitCount = MIN(self.currentVisibleItemMax,
                                              [self.storiesList count]);
    
    int i = 0;
    for(NSNumber * identifier in self.storiesList) {
        
        if([self.itemsLoadStatus[identifier] isEqual:@(StoryLoadStatusLoading)] ||
           [self.itemsLoadStatus[identifier] isEqual:@(StoryLoadStatusLoaded)]) {
            i++; continue;
            
        } else {
         
            self.itemsLoadStatus[identifier] = @(StoryLoadStatusNotLoaded);
            
            if(i < self.currentVisibleItemMax) {
                
                self.itemsLoadStatus[identifier] = @(StoryLoadStatusLoading);
                
                [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {
                    
                    self.itemsLookup[identifier] = story;
                    self.itemsLoadStatus[identifier] = @(StoryLoadStatusLoaded);
                    
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
- (void)loadMoreItems {
    NSLog(@"StoriesViewController, loadMoreItems");
    
    self.loadingProgress.completedUnitCount = 0;
    self.loadingProgress.totalUnitCount = 20;
    
    self.currentVisibleItemMax += 20;
    [self loadVisibleItems];
}

#pragma mark - KVO Callback Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    NSNumber * fractionCompleted = change[NSKeyValueChangeNewKey];
    if([fractionCompleted floatValue] == 1.0f) {
        if(!self.loadingView.hidden) {
            self.loadingView.hidden = YES;
        }
    }
}


@end
