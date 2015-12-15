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
- (void)cancelPendingOperation:(id)sender;

// Used to determine which item is currently 'expanded' (showing action drawer)
@property (nonatomic, strong) NSMutableArray < Story * > * storiesObjectsList;

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
    
    _awaitingSecondMoveOperation = NO;
    
    self.storiesObjectsList = [[NSMutableArray alloc] init];
    
    // Transient storage so the cellForRow method can pickup a pending
    // diff to associate with a story that has been updated by Firebase
    self.storiesList = [[NSMutableArray alloc] init];
    
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon"] style:
                                             UIBarButtonItemStylePlain target:self action:@selector(didTapSettingsIcon:)];
    
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

#pragma mark - IASKSettingsDelegate Methods
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate updateNightMode];
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
    
    NSDictionary * specifierDict = specifier.specifierDict;
    if([[specifierDict allKeys] containsObject:@"Key"] && [specifierDict[@"Key"] isEqualToString:@"loginToAccount"]) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self performSegueWithIdentifier:@"showLogin" sender:nil];
        }];
    }
}

#pragma mark - Private Methods
- (void)didTapSettingsIcon:(id)sender {
    
    IASKAppSettingsViewController * controller = [[IASKAppSettingsViewController alloc] init];
    controller.delegate = self;
    controller.showCreditsFooter = NO;
    controller.settingsStore = [AppConfig sharedConfig];
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)loadContent:(id)sender {
    [super loadContent:nil];
    
    if([self.storiesList count] > 0) {
        
        [self.itemsLookup removeAllObjects];
        [self.itemsLoadStatus removeAllObjects];
        [self.storiesList removeAllObjects];
        [self.storiesObjectsList removeAllObjects];
        [self.visibleItems removeAllObjects];
        
        [self.tableView reloadData];
    }
    
    [self.ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        [self.storiesList addObjectsFromArray:snapshot.value];
        
        self.initialLoadDone = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        self.loadingProgress.completedUnitCount++;
        
        [self loadVisibleItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)loadVisibleItems {
    NSLog(@"loadVisibleItems");
    
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
        NSNumber * storyIdentifier = [self.storiesList objectAtIndex:i];
        [loadedItems addObject:storyIdentifier];
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
                
                NSLog(@"loading: %@", identifier);
                
                self.itemsLoadStatus[identifier] = @(StoryLoadStatusLoading);
                
                [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {
                    
                    if(story == nil) {
                        self.loadingProgress.completedUnitCount++;
                        
                    } else {
                        self.itemsLookup[identifier] = story;
                        self.itemsLoadStatus[identifier] = @(StoryLoadStatusLoaded);
                        
                        if(![_storiesObjectsList containsObject:story]) {
                            [self.storiesObjectsList addObject:story];
                        }
                        
                        story.ranking = @(i + 1);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            self.loadingProgress.completedUnitCount++;
                            [self.tableView reloadData];
                        });
                    }
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
        
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [self.refreshDateFormatter stringFromDate:[NSDate date]]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:
                                               @{ NSForegroundColorAttributeName: [UIColor grayColor] }];
        [self.refreshControl endRefreshing];
    }
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

- (void)storyCellDidDisplayActionDrawer:(StoryCell*)cell {
    
    Story * story = cell.story;
    NSArray * expandedStoryArray = [_storiesObjectsList filteredArrayUsingPredicate:
                                      [NSPredicate predicateWithFormat:@"sizeStatus == %lu", StorySizeStatusExpanded]];

    if([expandedStoryArray count] > 0) {
        Story * expandedStory = [expandedStoryArray firstObject];
        expandedStory.sizeStatus = CommentSizeStatusNormal;
        
        // Job done, don't expand again
        if(story == expandedStory) {
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            
            return;
        }
    }

    story.sizeStatus = StorySizeStatusExpanded;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
