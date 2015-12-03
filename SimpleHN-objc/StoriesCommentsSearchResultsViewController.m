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
//        _showsLoadMoreCell = YES;
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

- (void)clearAllResults {
    
    [self.storiesList removeAllObjects];
    [self.visibleItems removeAllObjects];
    [self.itemsLoadStatus removeAllObjects];
    [self.itemsLookup removeAllObjects];
    
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
    [self.tableView reloadData];
    
    if(!self.loadingView.hidden) {
        self.loadingView.hidden = YES;
    }
    
    [self updateSectionHeaderViewContent];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryCell * cell = (StoryCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.votingEnabled = NO;
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
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)updateSectionHeaderViewContent {
    _sectionHeaderView.loading = self.loading;
    _sectionHeaderView.totalResultsCount = self.totalResultsCount;
    
    if(_currentPage == 0) {
        _sectionHeaderView.currentResultStart = 0;
        _sectionHeaderView.currentResultEnd = 0;
        
    } else {
        _sectionHeaderView.currentResultStart = ((self.currentPage - 1) * 20) + 1;
        _sectionHeaderView.currentResultEnd = self.currentPage * 20;
    }
}

#pragma mark - StoriesCommentsSearchFilterViewControllerDelegate Methods
- (void)storiesCommentsSearchFilterViewControllerDelegate:(StoriesCommentsSearchFilterViewController*)controller
                                          didSelectFilter:(NSNumber*)filter {
    NSLog(@"storiesCommentsSearchFilterViewControllerDelegate: didSelectFilter:");
    
    
}

@end
