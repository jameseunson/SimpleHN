//
//  StoriesSearchViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StoriesSearchViewController.h"
#import "SimpleHNWebViewController.h"

@interface StoriesSearchViewController ()

- (void)didTapCancelItem:(id)sender;
- (void)processAlgoliaSearchResult:(NSDictionary*)result;

@end

@implementation StoriesSearchViewController

- (void)loadView {
    [super loadView];
    
    self.recentQueriesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _recentQueriesTableView.delegate = self;
    _recentQueriesTableView.dataSource = self;
    _recentQueriesTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_recentQueriesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
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
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                             UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelItem:)];
}

- (void)query:(NSString*)query {
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
        self.recentQueriesTableView.backgroundColor = kNightDefaultColor;
        self.recentQueriesTableView.separatorColor = UIColorFromRGB(0x555555);
        
        self.searchController.searchBar.barTintColor = UIColorFromRGB(0x222222);
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        
    } else {
        self.recentQueriesTableView.backgroundColor = UIColorFromRGB(0xffffff);
        self.recentQueriesTableView.separatorColor = self.defaultSeparatorColor;
        
        self.searchController.searchBar.barTintColor = nil;
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    }
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

#pragma mark - StoriesCommentsSearchResultsViewControllerDelegate
- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)controller didSelectResult:(id)result {
    
    //    if(self.splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
    //        [self.searchController setActive:NO];
    //    }
    
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

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
