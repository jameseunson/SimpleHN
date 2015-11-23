//
//  StoriesCommentsSearchResultsViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 18/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsBaseViewController.h"

@protocol StoriesCommentsSearchResultsViewControllerDelegate;
@interface StoriesCommentsSearchResultsViewController : StoriesCommentsBaseViewController

@property (nonatomic, assign) __unsafe_unretained id<StoriesCommentsSearchResultsViewControllerDelegate> delegate;

@end

@protocol StoriesCommentsSearchResultsViewControllerDelegate <NSObject>
- (void)storiesCommentsSearchResultsViewController:(StoriesCommentsSearchResultsViewController*)
    controller didSelectResult:(id)result;
@end