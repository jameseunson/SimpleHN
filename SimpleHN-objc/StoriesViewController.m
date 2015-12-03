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

#define kAPIExpectedItemsCount 500

@interface StoriesViewController ()

- (void)loadVisibleItems;
- (void)cancelPendingOperation:(id)sender;

//@property (nonatomic, strong) NSMutableArray < NSNumber * > * storiesList;
@property (nonatomic, strong) NSMutableDictionary * storyDiffLookup; // NYI

// Ignore
@property (nonatomic, assign) BOOL initialLoadDone;

@property (nonatomic, assign) BOOL awaitingSecondMoveOperation;
@property (nonatomic, strong) NSArray * pendingMoveOperation;
@property (nonatomic, strong) NSTimer * pendingOperationTimer;


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
    
    _initialLoadDone = NO;
    _awaitingSecondMoveOperation = NO;
    
    // Transient storage so the cellForRow method can pickup a pending
    // diff to associate with a story that has been updated by Firebase
    self.storyDiffLookup = [[NSMutableDictionary alloc] init];
    
//    self.storiesList = [[NSMutableArray alloc] init];
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    
    [self.loadingProgress removeObserver:self
                              forKeyPath:@"fractionCompleted"];
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:21];
    [self.loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                          options:NSKeyValueObservingOptionNew context:NULL];
    
    masterProgress.completedUnitCount = 0;
    masterProgress.totalUnitCount = 21;
    [masterProgress addChild:self.loadingProgress withPendingUnitCount:21];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView setContentOffset:CGPointMake(0, 44.0f)];
    
    self.detailViewController = ((SimpleHNSplitViewController*)
                                 self.splitViewController).storyDetailViewController;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        Story * story = nil;
        if(sender) { // Search result
            story = (Story*)sender;
            
        } else { // Everything else
            story = [self itemForIndexPath:
                     [self.tableView indexPathForSelectedRow]];
        }
        
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

    self.storiesList = [[FirebaseArray alloc] initWithRef:ref];
    _storiesList.delegate = self;
}

- (void)loadVisibleItems {
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    
    [self.loadingProgress removeObserver:self
                              forKeyPath:@"fractionCompleted"];
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:20];
    [self.loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                              options:NSKeyValueObservingOptionNew context:NULL];
    
    masterProgress.completedUnitCount = 0;
    masterProgress.totalUnitCount = 20;
    [masterProgress addChild:self.loadingProgress withPendingUnitCount:20];
    
    if([self.storiesList count] > self.currentVisibleItemMax) {
        self.shouldDisplayLoadMoreCell = YES;
    } else {
        self.shouldDisplayLoadMoreCell = NO;
    }
    
    [self.visibleItems removeAllObjects];

    NSMutableArray * loadedItems = [[NSMutableArray alloc] init];
    
    NSInteger currentMax = MIN(self.currentVisibleItemMax, [self.storiesList count]);
    for(NSInteger i = 0; i < currentMax; i++) {
        FDataSnapshot * snap = [self.storiesList objectAtIndex:i];
        [loadedItems addObject:snap.value];
    }
    
    [self.visibleItems addObjectsFromArray:loadedItems];
    
    int i = 0;
    for(NSNumber * identifier in loadedItems) {
        
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
                    
                    story.ranking = @(i + 1);
                    
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
            
            _initialLoadDone = YES;
        }
    }
}

#pragma mark - FirebaseArrayDelegate Methods
- (void)childAdded:(id)object atIndex:(NSUInteger)index {
    
    if([self.storiesList count] == kAPIExpectedItemsCount) {
        
        _initialLoadDone = YES;
        self.loadingProgress.completedUnitCount++;        
        
        [self loadVisibleItems];
    }
}

- (void)childChanged:(id)object atIndex:(NSUInteger)index {
    
    if(!_initialLoadDone) {
        NSLog(@"change before initial load, ignoring");
        return;
    }
    
    FDataSnapshot * snap = [self.storiesList objectAtIndex:index];
    NSNumber * identifier = snap.value;
    
    if(index >= self.currentVisibleItemMax) {
        return;
    }
    
    NSNumber * previousIdentifier = self.visibleItems[index];
    
    if([identifier isEqual:previousIdentifier]) { // Item update
        
        __block Story * previousStory = self.itemsLookup[identifier];
        [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {

            NSDictionary * diff = [previousStory diffOtherStory:story];

            self.itemsLookup[identifier] = story;
            self.itemsLoadStatus[identifier] = @(StoryLoadStatusLoaded);

            NSLog(@"diff: %@", diff);

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"updating tableview for story with identifier: %@", identifier);

                NSInteger indexOfStory = [self.visibleItems indexOfObject:identifier];
                if(indexOfStory != NSNotFound) {
                    
                    NSIndexPath * reloadIndexPath = [NSIndexPath indexPathForRow:indexOfStory inSection:0];
                    if(reloadIndexPath) {
                        
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:@[ reloadIndexPath ]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.tableView endUpdates];
                        NSLog(@"done updating tableview for story at index: %lu", indexOfStory);
                    }
                }
            });
        }];
        
        
    } else { // Item position move
        
        if(_awaitingSecondMoveOperation) {
            _awaitingSecondMoveOperation = NO;
            NSLog(@"Detected second of a two part move operation");
            
            if(!_pendingMoveOperation) {
                [self cancelPendingOperation:nil];
                return;
            }
            
            NSInteger previousIndex = [[_pendingMoveOperation lastObject] integerValue];
            NSInteger currentIndex = index;
            
            NSIndexPath * previousIndexPath = [NSIndexPath indexPathForRow:previousIndex inSection:0];
            NSIndexPath * currentIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
            
            NSLog(@"%@ -> %@", previousIndexPath, currentIndexPath);
            
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MIN(previousIndex, currentIndex) inSection:0]
//                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            [self.tableView beginUpdates];
            
            [self.visibleItems exchangeObjectAtIndex:currentIndex withObjectAtIndex:previousIndex];
            
            [self.tableView moveRowAtIndexPath:previousIndexPath toIndexPath:currentIndexPath];
            [self.tableView moveRowAtIndexPath:currentIndexPath toIndexPath:previousIndexPath];
            
            [self.tableView endUpdates];
            
            [self cancelPendingOperation:nil];
            
            for(NSNumber * index in @[ @(previousIndex), @(currentIndex) ]) {
                
                NSNumber * identifier = self.visibleItems[[index integerValue]];
                self.itemsLoadStatus[identifier] = @(StoryLoadStatusLoading);
                
                __block Story * previousStory = self.itemsLookup[identifier];
                
                [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {
                    
                    self.itemsLookup[identifier] = story;
                    self.itemsLoadStatus[identifier] = @(StoryLoadStatusLoaded);
                    
                    story.ranking = index;
                    
                    story.diff = [story diffOtherStory:previousStory];
                    NSLog(@"diff: %@", story.diff);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:[index integerValue] inSection:0] ]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                }];
            }
            
        } else {
            
            [self cancelPendingOperation:nil];
            
            NSLog(@"Detected first of a two part move operation at index: %lu", index);
            _awaitingSecondMoveOperation = YES;
            
            _pendingMoveOperation = @[ identifier, previousIdentifier, @(index) ];

            self.pendingOperationTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSDate date] timeIntervalSinceNow] + 1.5
                                                                          target:self selector:@selector(cancelPendingOperation:) userInfo:nil repeats:NO];
        }
    }
}

- (void)childRemoved:(id)object atIndex:(NSUInteger)index {
    NSLog(@"childRemoved: %lu", index);
}

- (void)childMoved:(id)object fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSLog(@"childMoved: %lu, %lu", fromIndex, toIndex);
}

- (void)cancelPendingOperation:(id)sender {
    
    if(sender) {
        NSLog(@"cancelPendingOperation: AS A RESULT OF SECOND OPERATION NOT BEING SENT");
        
    } else {
        NSLog(@"cancelPendingOperation:");
    }
    if(_pendingOperationTimer) {
        [_pendingOperationTimer invalidate];
        _pendingOperationTimer = nil;
    }
    _awaitingSecondMoveOperation = NO;
    _pendingMoveOperation = nil;
}

@end
