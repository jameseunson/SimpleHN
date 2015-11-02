//
//  CommentCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 2/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "KILabel.h"

@protocol CommentCellDelegate;
@interface CommentCell : UITableViewCell

@property (nonatomic, strong) Comment * comment;

@property (nonatomic, strong) KILabel * commentLabel;

@property (nonatomic, strong) UIStackView * headerStackView;
@property (nonatomic, strong) UILabel * authorLabel;
@property (nonatomic, strong) UILabel * dateLabel;

@property (nonatomic, strong) CALayer * headerBorderLayer;
@property (nonatomic, strong) UIView * headerBackgroundView;
//@property (nonatomic, strong) UIImageView * headerIconImageView;
@property (nonatomic, strong) UILabel * headerUpDownLabel;

@property (nonatomic, assign) __unsafe_unretained id<CommentCellDelegate> delegate;

@end

@protocol CommentCellDelegate <NSObject>
- (void)commentCell:(CommentCell*)cell didTapLink:(CommentLink*)link;
@end
