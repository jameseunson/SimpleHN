//
//  StoryCommentBaseTableViewCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 3/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCommentBaseTableViewCell.h"

@interface StoryCommentBaseTableViewCell ()

@property (nonatomic, strong) UIImageView * upvoteImageView;
@property (nonatomic, strong) UIImageView * upvoteConfirmedImageView;

@property (nonatomic, strong) UIImageView * downvoteImageView;
@property (nonatomic, strong) UIImageView * downvoteConfirmedImageView;

@end

@implementation StoryCommentBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
        _votingEnabled = YES;
        
        self.firstTrigger = 0.15;
        self.secondTrigger = 0.5;
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // Configuring the views and colors.
        self.upvoteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"story-cell-upvote-icon"]];
        _upvoteImageView.backgroundColor = [UIColor orangeColor];
        _upvoteImageView.contentMode = UIViewContentModeCenter;
        
        self.upvoteConfirmedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"story-cell-upvote-confirmed-icon"]];
        _upvoteConfirmedImageView.backgroundColor = [UIColor orangeColor];
        _upvoteConfirmedImageView.contentMode = UIViewContentModeCenter;
        
        self.downvoteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"story-cell-downvote-icon"]];
        _downvoteImageView.backgroundColor = RGBCOLOR(88, 86, 214);
        _downvoteImageView.contentMode = UIViewContentModeCenter;
        
        self.downvoteConfirmedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"story-cell-downvote-confirmed-icon"]];
        _downvoteConfirmedImageView.backgroundColor = RGBCOLOR(88, 86, 214);
        _downvoteConfirmedImageView.contentMode = UIViewContentModeCenter;
    
        [self setDefaultColor:[UIColor whiteColor]];
        
        // Adding gestures per state basis.
        [self setSwipeGestureWithView:_downvoteImageView color:RGBCOLOR(88, 86, 214) mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:nil];
        
        [self setSwipeGestureWithView:_downvoteConfirmedImageView color:RGBCOLOR(88, 86, 214) mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            NSLog(@"Did swipe \"Downvote\" cell");
        }];
        
        [self setSwipeGestureWithView:_upvoteImageView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:nil];
        
        [self setSwipeGestureWithView:_upvoteConfirmedImageView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            NSLog(@"Did swipe \"Upvote\" cell");
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _upvoteImageView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
    _downvoteImageView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
}

- (void)setVotingEnabled:(BOOL)votingEnabled {
    _votingEnabled = votingEnabled;
    
    self.shouldDrag = votingEnabled;
}

@end