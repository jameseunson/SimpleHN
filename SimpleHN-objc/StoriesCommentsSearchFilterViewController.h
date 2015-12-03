//
//  StoriesCommentSearchFilterViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 3/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StoriesCommentsSearchFilterViewControllerDelegate;
@interface StoriesCommentsSearchFilterViewController : UITableViewController

@property (nonatomic, assign) __unsafe_unretained id<StoriesCommentsSearchFilterViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedPeriodIndex;
@property (nonatomic, strong) NSIndexPath * lastPeriodSelected;

@end

@protocol StoriesCommentsSearchFilterViewControllerDelegate <NSObject>
- (void)storiesCommentsSearchFilterViewControllerDelegate:(StoriesCommentsSearchFilterViewController*)controller
      didSelectFilter:(NSNumber*)filter;
@end