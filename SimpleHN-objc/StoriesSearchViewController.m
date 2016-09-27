//
//  StoriesSearchViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StoriesSearchViewController.h"
#import "SimpleHNWebViewController.h"

#define kTimePeriodCellReuseIdentifier @"timePeriodCellReuseIdentifier"
#define kSearchHistoryCellReuseIdentifier @"timePeriodCellReuseIdentifier"

@interface StoriesSearchViewController ()

- (void)didTapCancelItem:(id)sender;
- (void)processAlgoliaSearchResult:(NSDictionary*)result;

@property (nonatomic, assign) NSInteger selectedPeriodIndex;
@property (nonatomic, strong) NSIndexPath * lastPeriodSelected;

@end

@implementation StoriesSearchViewController

- (void)loadView {
    [super loadView];
    
    self.definesPresentationContext = YES;
    
    self.recentQueriesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _recentQueriesTableView.delegate = self;
    _recentQueriesTableView.dataSource = self;
    _recentQueriesTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.recentQueriesTableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kTimePeriodCellReuseIdentifier];
    [self.recentQueriesTableView registerClass:[UITableViewCell class]
                        forCellReuseIdentifier:kSearchHistoryCellReuseIdentifier];
    
    self.recentQueriesTableView.rowHeight = UITableViewAutomaticDimension;
    self.recentQueriesTableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
    [self.view addSubview:_recentQueriesTableView];
    
    self.searchResultsController = [[StoriesCommentsSearchResultsViewController alloc] init];
    _searchResultsController.delegate = self;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;

    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    _searchController.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44.0f);
    _recentQueriesTableView.tableHeaderView = _searchController.searchBar;
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_recentQueriesTableView);
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_recentQueriesTableView]|;V:|[_recentQueriesTableView]|" options:0 metrics:nil views:bindings]];
    
    [self updateNightMode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedPeriodIndex = 0;
    _lastPeriodSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    
    self.title = @"Search HN";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                             UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelItem:)];
}

- (void)query:(NSString*)query {
    
    [[AppConfig sharedConfig] addRecentQuery:query];
    [_recentQueriesTableView reloadData];
    
    [[HNAlgoliaAPIManager sharedManager] query:query withTimePeriod:[[AppConfig sharedConfig] activeSearchFilter]
                                      withPage:0 withCompletion:^(NSDictionary *result) {
                                          [self processAlgoliaSearchResult:result];
                                      }];
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

#pragma mark - Override Methods
- (void)updateNightMode {
    [super updateNightMode];
    
    NSLog(@"updateNightMode");
    
    if(!self.defaultSeparatorColor) {
        self.defaultSeparatorColor = self.recentQueriesTableView.separatorColor;
    }
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.searchController.searchBar.barStyle = UIBarStyleBlack;
        
        self.recentQueriesTableView.backgroundColor = self.view.backgroundColor = kNightDefaultColor;
        self.recentQueriesTableView.separatorColor = UIColorFromRGB(0x555555);
        
        self.searchController.searchBar.barTintColor = UIColorFromRGB(0x222222);
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        
    } else {
        
        self.searchController.searchBar.barStyle = UIBarStyleDefault;
        
        self.recentQueriesTableView.backgroundColor = self.view.backgroundColor = UIColorFromRGB(0xffffff);
        self.recentQueriesTableView.separatorColor = self.defaultSeparatorColor;
        
        self.searchController.searchBar.barTintColor = nil;
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    }
    
    [self.recentQueriesTableView reloadData];
}

- (void)didTapCancelItem:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchResultsUpdating Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    UISearchBar * searchBar = _searchController.searchBar;
    NSString * query = searchBar.text;
    
    [self.searchResultsController clearAllResults];
    
    if([query isEqualToString:self.activeQuery]) {
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

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [kTimePeriods count];
        
    } else if(section == 1) {
        
        if([[[AppConfig sharedConfig] searchRecentQueries] count] == 0) {
            return 1;
            
        } else {
            return MIN([[[AppConfig sharedConfig] searchRecentQueries] count], 5);
        }
        
    } else {
        if([[[AppConfig sharedConfig] searchRecentQueries] count] == 0) {
            return 0;
        } else {
            return 1; // Clear button
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = nil;
    if(indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:
                                  kTimePeriodCellReuseIdentifier forIndexPath:indexPath];
        cell.textLabel.text = kTimePeriodsLookup[kTimePeriods[indexPath.row]];
        
        if(_selectedPeriodIndex == [indexPath row]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:
                kSearchHistoryCellReuseIdentifier forIndexPath:indexPath];
        
        if(indexPath.section == 1) {
            if([[[AppConfig sharedConfig] searchRecentQueries] count] == 0) {
                cell.textLabel.text = @"No recent searches";
            } else {
                cell.textLabel.text = [[AppConfig sharedConfig] searchRecentQueries][indexPath.row];
            }
        } else {
            cell.textLabel.text = @"Clear Search History";
        }
    }
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        cell.nightBackgroundColor = kNightDefaultColor;
        cell.textLabel.nightTextColor = UIColorFromRGB(0xffffff);
        
    } else {
        cell.backgroundColor = UIColorFromRGB(0xffffff);
        cell.textLabel.textColor = UIColorFromRGB(0x000000);
    }
    
    if(indexPath.section == 1 && [[[AppConfig sharedConfig] searchRecentQueries] count] == 0) {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if(indexPath.section == 2) {
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Time Period";
        
    } else if(section == 1) {
        return @"Recent Searches";
        
    } else {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && [[[AppConfig sharedConfig] searchRecentQueries] count] > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0) {
     
        _selectedPeriodIndex = [indexPath row];
        [tableView cellForRowAtIndexPath:_lastPeriodSelected].accessoryType = UITableViewCellAccessoryNone;
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
        self.lastPeriodSelected = indexPath;
        
        NSNumber * period = kTimePeriods[[indexPath row]];
        [[AppConfig sharedConfig] setInteger:[period integerValue] forKey:kActiveSearchFilter];
        
    } else if(indexPath.section == 1) {
        
        if([[[AppConfig sharedConfig] searchRecentQueries] count] > 0) {
            NSString * query = [[AppConfig sharedConfig] searchRecentQueries][indexPath.row];
            
            self.searchController.searchBar.text = query;
            self.activeQuery = query;
            
            [self query:query];
            [self.searchController setActive:YES];
        }
        
    } else {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:
                                               @"Clear Search History?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[AppConfig sharedConfig] setObject:@[] forKey:kSearchRecentQueries];
            [_recentQueriesTableView reloadData];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - StoriesCommentsSearchResultsViewControllerDelegate
- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)controller didSelectResult:(id)result {

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
    
    NSString * query = self.activeQuery;
    [[HNAlgoliaAPIManager sharedManager] query:query withTimePeriod:[[AppConfig sharedConfig] activeSearchFilter]
                                      withPage:[pageNumber integerValue] withCompletion:^(NSDictionary *result) {
                                          [self processAlgoliaSearchResult:result];
                                      }];
}

- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
controller didChangeTimePeriod:(NSNumber*)timePeriod {
    
    NSString * query = self.activeQuery;
    [[HNAlgoliaAPIManager sharedManager] query:query withTimePeriod:[[AppConfig sharedConfig] activeSearchFilter]
                                      withPage:0 withCompletion:^(NSDictionary *result) {
                                          [self processAlgoliaSearchResult:result];
                                      }];
}

@end
