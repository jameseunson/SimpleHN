//
//  StoriesSearchViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleHNNightModeViewController.h"
#import "StoriesCommentsSearchResultsViewController.h"

@interface StoriesSearchViewController : SimpleHNNightModeViewController <UISearchResultsUpdating,
    UISearchControllerDelegate, UISearchBarDelegate, StoriesCommentsSearchResultsViewControllerDelegate,
    UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController * searchController;
@property (nonatomic, strong) StoriesCommentsSearchResultsViewController * searchResultsController;
@property (nonatomic, strong) UITableView * recentQueriesTableView;

@property (nonatomic, assign) BOOL pendingSearchOperation;
@property (nonatomic, strong) NSString * pendingSearchQuery;
@property (nonatomic, strong) NSString * activeQuery;

- (void)query:(NSString*)query;

@end
