//
//  StoryLoadMoreCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 3/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StoryLoadMoreCellState) {
    StoryLoadMoreCellStateNormal, // Pull to load more
    StoryLoadMoreCellStateTransition, // Keep pulling
    StoryLoadMoreCellStateLoading // Loading
};

@interface StoryLoadMoreCell : UITableViewCell

@property (nonatomic, assign) StoryLoadMoreCellState state;

@property (nonatomic, strong) UILabel * loadMoreLabel;
@property (nonatomic, strong) UILabel * loadMoreSubtitleLabel;

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;

@end
