//
//  StoriesCommentsSearchResultsViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 18/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsSearchResultsViewController.h"

@interface StoriesCommentsSearchResultsViewController ()

@property (nonatomic, strong) NSMutableArray < NSNumber * > * storiesList;

@property (nonatomic, strong) StoriesCommentsSearchResultsSectionHeaderView * sectionHeaderView;

@end

@implementation StoriesCommentsSearchResultsViewController

- (instancetype)init {
    if(self = [super init]) {
        self.storiesList = [[NSMutableArray alloc] init];
        
        [super awakeFromNib];
        
        _totalResultsCount = 0;
        _currentPage = 0;
        
        _loading = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.sectionHeaderView = [[StoriesCommentsSearchResultsSectionHeaderView alloc] initWithFrame:
                              CGRectMake(0, 0, self.view.frame.size.width, 55.0f)];
    
    _sectionHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _sectionHeaderView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.tableView.contentInset = UIEdgeInsetsMake(44.0f + [UIApplication sharedApplication].statusBarFrame.size.height, 0,
                                                   self.tabBarController.tabBar.frame.size.height + _sectionHeaderView.frame.size.height, 0);
}

#pragma mark - Public Methods
- (void)clearAllResults {
    
    [self.storiesList removeAllObjects];
    [self.visibleItems removeAllObjects];
    [self.itemsLoadStatus removeAllObjects];
    [self.itemsLookup removeAllObjects];
    
    self.shouldDisplayLoadMoreCell = NO;
    [self.tableView reloadData];
    
    [self updateSectionHeaderViewContent];
}

- (void)addSearchResults:(NSArray*)results {
    
    int i = 0;
    for(Story * story in results) {
        
        self.itemsLookup[story.storyId] = story;
        self.itemsLoadStatus[story.storyId] = @(StoryLoadStatusLoaded);
        [self.visibleItems addObject:story.storyId];
        
        i++;
    }
    
    self.initialLoadDone = YES;
    
    // Only display load more cell if there are actually more results to show 
    if(self.totalResultsCount > self.currentVisibleItemMax) {
        self.shouldDisplayLoadMoreCell = YES;
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(44.0f + [UIApplication sharedApplication].statusBarFrame.size.height, 0,
                                                   self.tabBarController.tabBar.frame.size.height + _sectionHeaderView.frame.size.height, 0);
    
    [self.tableView reloadData];
    
    [self updateSectionHeaderViewContent];
}

- (void)loadMoreItems {
    NSLog(@"StoriesCommentSearchResultsViewController, loadMoreItems");
    
    self.currentVisibleItemMax += 20;
    self.currentPage++;
    
    if([self.delegate respondsToSelector:@selector(storiesCommentsSearchResultsViewController:loadResultsForPageWithNumber:)]) {
        [self.delegate performSelector:@selector(storiesCommentsSearchResultsViewController:loadResultsForPageWithNumber:)
                            withObject:self withObject:@(_currentPage)];
    }
    
//    [self loadVisibleItems];
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == self.currentVisibleItemMax && [self.storiesList count] > 0) {
        [self loadMoreItems];
        
    } else {
        
        NSNumber * identifier = (NSNumber*)self.visibleItems[indexPath.row];
        Story * story = self.itemsLookup[identifier];
        
        if([self.delegate respondsToSelector:@selector(storiesCommentsSearchResultsViewController:didSelectResult:)]) {
            [self.delegate performSelector:@selector(storiesCommentsSearchResultsViewController:didSelectResult:)
                                withObject:self withObject:story];
        }
    }
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryCell * cell = (StoryCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if([cell isKindOfClass:[StoryCell class]]) {
        cell.votingEnabled = NO;
    }
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    [self updateSectionHeaderViewContent];
    return _sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSString * titleForSection = [self tableView:tableView titleForHeaderInSection:section];
    if(titleForSection && [titleForSection length] > 0) {
        
        return 55.0f;
    }
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Placeholder";
}

#pragma mark - StoriesCommentsSearchResultsSectionHeaderViewDelegate Methods
- (void)storiesCommentsSearchResultsSectionHeaderViewDidTapAdjustFilterButton:(StoriesCommentsSearchResultsSectionHeaderView *)view {

    StoriesCommentsSearchFilterViewController *controller = [[StoriesCommentsSearchFilterViewController alloc] init];
    [controller setDelegate: self];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - StoryCellDelegate Methods
- (void)storyCellDidTapCommentsArea:(StoryCell*)cell {
    
    if([self.delegate respondsToSelector:@selector(storiesCommentsSearchResultsViewController:didTapCommentsForResult:)]) {
        [self.delegate performSelector:@selector(storiesCommentsSearchResultsViewController:didTapCommentsForResult:)
                            withObject:self withObject:cell.story];
    }
}

#pragma mark - Private Methods
- (void)updateSectionHeaderViewContent {
    
    _sectionHeaderView.loading = self.loading;
    _sectionHeaderView.totalResultsCount = self.totalResultsCount;
    
    if(_currentPage == 0) {
        
        _sectionHeaderView.currentResultStart = 0;
        if(self.totalResultsCount == 0) {
            _sectionHeaderView.currentResultEnd = 0;
        } else {
            _sectionHeaderView.currentResultEnd = MIN(20, self.totalResultsCount);
        }
        
    } else {
        _sectionHeaderView.currentResultStart = ((self.currentPage - 1) * 20) + 1;
        _sectionHeaderView.currentResultEnd = MIN(self.currentPage * 20, self.totalResultsCount);
    }
    
    StoriesTimePeriods filter = [[AppConfig sharedConfig] activeSearchFilter];
    if(filter != StoriesTimePeriodsNoPeriod) {
        NSString * filterName = kTimePeriodsLookup[@(filter)];
        _sectionHeaderView.filterSubtitleLabel.text = [NSString stringWithFormat:@"Showing %@", filterName];
    } else {
        _sectionHeaderView.filterSubtitleLabel.text = @"Showing all results (no filter)";
    }
    [_sectionHeaderView setNeedsLayout];
}

#pragma mark - StoriesCommentsSearchFilterViewControllerDelegate Methods
- (void)storiesCommentsSearchFilterViewControllerDelegate:(StoriesCommentsSearchFilterViewController*)controller
                                          didSelectFilter:(NSNumber*)filter {
    NSLog(@"storiesCommentsSearchFilterViewControllerDelegate: didSelectFilter:");
    
    [[AppConfig sharedConfig] setInteger:[filter integerValue] forKey:kActiveSearchFilter];
    [self updateSectionHeaderViewContent];
    
    [self clearAllResults];
    
    if([self.delegate respondsToSelector:@selector(storiesCommentsSearchResultsViewController:didChangeTimePeriod:)]) {
        [self.delegate performSelector:@selector(storiesCommentsSearchResultsViewController:didChangeTimePeriod:)
                            withObject:self withObject:filter];
    }
}

@end
