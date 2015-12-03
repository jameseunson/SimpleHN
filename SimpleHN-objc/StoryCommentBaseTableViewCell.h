//
//  StoryCommentBaseTableViewCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 3/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@protocol StoryCommentVotingTableViewCellDelegate;
@interface StoryCommentBaseTableViewCell : MCSwipeTableViewCell

@property (nonatomic, assign) __unsafe_unretained id<StoryCommentVotingTableViewCellDelegate> votingDelegate;

@property (nonatomic, assign, getter=isVotingEnabled) BOOL votingEnabled;

@end

@protocol StoryCommentVotingTableViewCellDelegate <NSObject>
@required
- (void)storyCommentCellDidUpvote:(StoryCommentBaseTableViewCell*)cell;
- (void)storyCommentCellDidDownvote:(StoryCommentBaseTableViewCell*)cell;
@end