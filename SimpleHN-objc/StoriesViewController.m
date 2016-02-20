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
#import "SimpleHNWebViewController.h"
#import "SettingsVersionTableViewCell.h"
#import "VTAcknowledgementsViewController.h"

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

@property (nonatomic, strong) UIBarButtonItem * timePeriodItem;

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
    _storyType = StoryTypeDefault;
    
    self.storiesObjectsList = [[NSMutableArray alloc] init];
    self.selectedTimePeriodStories = [[NSMutableArray alloc] init];
    
    self.selectedTimePeriod = [[kTimePeriods firstObject] intValue]; // Now
    
    // Transient storage so the cellForRow method can pickup a pending
    // diff to associate with a story that has been updated by Firebase
    self.storiesList = [[NSMutableArray alloc] init];
    
//    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
//                                                   delegate]).masterProgress;
    
    [self.loadingProgress removeObserver:self
                              forKeyPath:@"fractionCompleted"];
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:21];
    [self.loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                          options:NSKeyValueObservingOptionNew context:NULL];
    
//    masterProgress.completedUnitCount = 0;
//    masterProgress.totalUnitCount = 21;
//    [masterProgress addChild:self.loadingProgress withPendingUnitCount:21];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[Crashlytics sharedInstance] crash];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView setContentOffset:CGPointMake(0, 44.0f)];
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.searchController.searchBar.barTintColor = UIColorFromRGB(0x222222);
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        
    } else {
        self.searchController.searchBar.barTintColor = nil;
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon"] style:
                                             UIBarButtonItemStylePlain target:self action:@selector(didTapSettingsIcon:)];
    
//    self.detailViewController = ((SimpleHNSplitViewController*)
//                                 self.splitViewController).storyDetailViewController;
    
    self.timePeriodItem = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:
                           UIBarButtonItemStylePlain target:self action:@selector(didTapTimePeriodItem:)];
    self.navigationItem.rightBarButtonItem = _timePeriodItem;
    
    self.splitViewController.delegate = self;
    
//    [[Crashlytics sharedInstance] crash];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addSubview:[ProgressBarView sharedProgressBarView]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[ProgressBarView sharedProgressBarView] removeFromSuperview];
}

#pragma mark - UISplitViewControllerDelegate Methods
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[StoryDetailViewController class]]
        && ([(StoryDetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // If the detail controller doesn't have an item, display the primary view controller instead
        return YES;
    }
    
    return NO;
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
        
    } else if([[segue identifier] isEqualToString:@"showWeb"]) {
        
        SimpleHNWebViewController *controller = (SimpleHNWebViewController *)
        [[segue destinationViewController] topViewController];
        controller.selectedStory = sender;
        
        controller.navigationItem.leftBarButtonItem =
        self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    } else if ([[segue identifier] isEqualToString:@"showTimePeriodSelect"]) {
        
        StoriesTimePeriodSelectViewController *controller = (StoriesTimePeriodSelectViewController *)
            [[segue destinationViewController] topViewController];
        controller.delegate = self;
        
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.selectedTimePeriod == StoriesTimePeriodsNow) {
        return [super tableView:tableView numberOfRowsInSection:section];
        
    } else {
        
        NSInteger itemsCount = [self.selectedTimePeriodStories count];
        if(itemsCount > 0) {
            itemsCount = itemsCount + 1;
        }
        return itemsCount;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(self.selectedTimePeriod == StoriesTimePeriodsNow) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
    } else {
        
        if(indexPath.row == [self.selectedTimePeriodStories count]) {
            StoryLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                       kStoryLoadMoreCellReuseIdentifier forIndexPath:indexPath];
            return cell;
            
        } else {
            
            StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                               kStoryCellReuseIdentifier forIndexPath:indexPath];
            cell.story = self.selectedTimePeriodStories[indexPath.row];
            
            cell.storyCellDelegate = self;
            cell.votingDelegate = self;
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.selectedTimePeriod == StoriesTimePeriodsNow) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        
    } else {
        if(indexPath.row == [self.selectedTimePeriodStories count]) {
            return 60.0f;
            
        } else {
            return [StoryCell heightForStoryCellWithStory:self.selectedTimePeriodStories[indexPath.row]
                                                    width:tableView.frame.size.width];
        }
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(!self.initialLoadDone) {
        return;
    }
    
    Story * selectedStory = nil;
    
    if(self.selectedTimePeriod == StoriesTimePeriodsNow) {
        if(indexPath.row == self.currentVisibleItemMax && [self.storiesList count] > 0) {
            [self loadMoreItems];
            return;
            
        } else {
            selectedStory = (Story*)[self itemForIndexPath:indexPath];
        }
    } else {
        if(indexPath.row == [self.selectedTimePeriodStories count]) {
            [self loadMoreItems];
            return;
            
        } else {
            selectedStory = self.selectedTimePeriodStories[indexPath.row];
        }
    }
    
    if(self.storyType == StoryTypeAskHN || !selectedStory.url) { // Ask HN item, or Show HN item without a url
        [self performSegueWithIdentifier:@"showDetail" sender:selectedStory];
        
    } else {
        [self performSegueWithIdentifier:@"showWeb" sender:selectedStory];
    }
}

- (void)reloadContent:(id)sender {
    [self loadContent:nil];
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

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier {
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier {
    
    if([specifier.specifierDict[@"Key"] isEqualToString:@"acknowledgementsCell"]) {
        
        UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        cell.textLabel.text = @"Acknowledgements";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    } else {
        return [[SettingsVersionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender tableView:(UITableView *)tableView didSelectCustomViewSpecifier:(IASKSpecifier*)specifier {
    if([specifier.specifierDict[@"Key"] isEqualToString:@"acknowledgementsCell"]) {
        
        VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
        [sender.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - StoriesTimePeriodSelectViewController Methods
- (void)storiesTimePeriodSelectViewController:(StoriesTimePeriodSelectViewController*)controller
                  didChangeSelectedTimePeriod:(NSNumber*)period {
    NSLog(@"storiesTimePeriodSelectViewController:didChangeSelectedTimePeriod:");
    
    self.timePeriodItem.title = kTimePeriodsLookup[period];
    
    self.selectedTimePeriod = [period intValue];
    [self.selectedTimePeriodStories removeAllObjects];
    
    self.initialLoadDone = NO;
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)storiesTimePeriodSelectViewControllerDidCancelSelect:(StoriesTimePeriodSelectViewController*)controller {
    NSLog(@"storiesTimePeriodSelectViewControllerDidCancelSelect:");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)didTapTimePeriodItem:(id)sender {
    [self performSegueWithIdentifier:@"showTimePeriodSelect" sender:nil];
}

#pragma mark - Private Methods
- (void)didTapSettingsIcon:(id)sender {
    
    IASKAppSettingsViewController * controller = [[IASKAppSettingsViewController alloc] init];
    controller.delegate = self;
    controller.showCreditsFooter = NO;
    controller.settingsStore = [AppConfig sharedConfig];
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    
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
//                NSLog(@"loading: %@", identifier);
                
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

    [ProgressBarView sharedProgressBarView].progress = [fractionCompleted floatValue];
    
    if([fractionCompleted floatValue] == 1.0f) {
        
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [self.refreshDateFormatter stringFromDate:[NSDate date]]];
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:
                                                   @{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
        } else {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:
                                                   @{ NSForegroundColorAttributeName: [UIColor grayColor] }];
        }
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
