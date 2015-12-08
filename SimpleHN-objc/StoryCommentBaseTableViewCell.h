//
//  StoryCommentBaseTableViewCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 3/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"
#import "StoryCommentUserVote.h"

@protocol StoryCommentVotingTableViewCellDelegate;
@interface StoryCommentBaseTableViewCell : MCSwipeTableViewCell

@property (nonatomic, assign) __unsafe_unretained id<StoryCommentVotingTableViewCellDelegate> votingDelegate;

@property (nonatomic, assign, getter=isVotingEnabled) BOOL votingEnabled;

@property (nonatomic, strong) UIImageView * upvoteCornerImageView;
@property (nonatomic, strong) UIImageView * downvoteCornerImageView;

// To be overriden in subclasses
- (void)didVoteWithType:(StoryCommentUserVote)voteType;

@end

@protocol StoryCommentVotingTableViewCellDelegate <NSObject>
@required
- (void)storyCommentCellDidVote:(StoryCommentBaseTableViewCell*)cell
                       voteType:(NSNumber*)voteType;
@end