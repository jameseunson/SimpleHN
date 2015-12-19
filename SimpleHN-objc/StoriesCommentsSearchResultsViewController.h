//
//  StoriesCommentsSearchResultsViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 18/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsBaseViewController.h"
#import "StoriesCommentsSearchResultsSectionHeaderView.h"
#import "StoriesCommentsSearchFilterViewController.h"

@protocol StoriesCommentsSearchResultsViewControllerDelegate;
@interface StoriesCommentsSearchResultsViewController : StoriesCommentsBaseViewController <StoriesCommentsSearchResultsSectionHeaderViewDelegate,
    StoriesCommentsSearchFilterViewControllerDelegate>

@property (nonatomic, assign) __unsafe_unretained id<StoriesCommentsSearchResultsViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL loading;

@property (nonatomic, assign) NSInteger totalResultsCount;
@property (nonatomic, assign) NSInteger currentPage;

- (void)addSearchResults:(NSArray*)results;
- (void)clearAllResults;

@end

@protocol StoriesCommentsSearchResultsViewControllerDelegate <NSObject>
- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
    controller didSelectResult:(id)result;

- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
controller didTapCommentsForResult:(id)result;

- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
    controller loadResultsForPageWithNumber:(NSNumber*)pageNumber;

- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
    controller didChangeTimePeriod:(NSNumber*)timePeriod;
@end