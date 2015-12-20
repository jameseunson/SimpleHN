//
//  CommentCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 2/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "CommentCell.h"
#import "JBNSLayoutConstraint+Install.h"
#import "ActionDrawerButton.h"
#import "RegexKitLite.h"

@import SafariServices;

@interface CommentCell ()

@property (nonatomic, strong) UITapGestureRecognizer * headerBackgroundViewTapGestureRecognizer;

- (void)didTapBackgroundView:(id)sender;
//- (void)commentCollapsedChanged:(NSNotification*)notification;

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

@end

@implementation CommentCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.commentLabel = [LabelHelper tttLabelWithFont:[LabelHelper adjustedBodyFont]];
        _commentLabel.delegate = self;
        [self.contentView addSubview:_commentLabel];
        
        self.headerView = [[CommentCellHeaderView alloc] init];
        _headerView.hidden = YES;
        [self.contentView addSubview:_headerView];
        
        self.actionDrawerView = [[ActionDrawerView alloc] init];
        _actionDrawerView.delegate = self;
        _actionDrawerView.hidden = YES;
        _actionDrawerView.contextType = ActionDrawerViewContextTypeDetail;
        [self.contentView addSubview:_actionDrawerView];
        
        self.headerBackgroundViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(didTapBackgroundView:)];
        [self.headerView addGestureRecognizer:_headerBackgroundViewTapGestureRecognizer];
        
        [self updateNightMode];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionNightFallingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionDawnComingNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    NSLog(@"commentCell, layoutSubviews for cell with comment: %@, %@", _comment.commentId, _comment.author);
    
    if(_comment.sizeStatus == CommentSizeStatusExpanded) {
        _actionDrawerView.hidden = NO;
        _commentLabel.hidden = NO;
        
        _headerView.collapsed = NO;
        if(_comment) {
            _headerView.hidden = NO;
        } else {
            _headerView.hidden = YES;
        }
//        self.votingEnabled = YES;
        
    } else if(_comment.sizeStatus == CommentSizeStatusNormal) {
        _actionDrawerView.hidden = YES;
        _commentLabel.hidden = NO;
        
        _headerView.collapsed = NO;
        if(_comment) {
            _headerView.hidden = NO;
        } else {
            _headerView.hidden = YES;
        }
//        self.votingEnabled = YES;
        
    } else if(_comment.sizeStatus == CommentSizeStatusCollapsed) {
        _actionDrawerView.hidden = YES;
        
        _commentLabel.hidden = YES;
        
        if(self.comment.parentComment.sizeStatus == CommentSizeStatusCollapsed) {
            _headerView.hidden = YES;
        } else {
            _headerView.hidden = NO;
            _headerView.collapsed = YES;
        }
//        self.votingEnabled = NO;
    }
    
    if(_comment.sizeStatus == CommentSizeStatusCollapsed) {
        if(_comment.parentComment.sizeStatus == CommentSizeStatusCollapsed) {
//            NSLog(@"comment and comment parent are collapsed, return early");
            return;
        }
    }
    
    _headerView.frame = CGRectMake(0, 0, self.frame.size.width, _headerView.intrinsicContentSize.height);
    
    CGSize sizeForCommentLabel = CGSizeZero;
    
    CGFloat commentRightMargin = 20.f;
    CGFloat commentLeftMargin = 20.f;
    
    if(self.comment && _comment.sizeStatus != CommentSizeStatusCollapsed && [self.comment.attributedText length] > 0) {
        
        if(self.comment.sizeStatus == CommentSizeStatusNormal) {
            commentLeftMargin = (20.0f * (self.comment.indentation + 1));
        }
        if(self.comment.sizeStatus == CommentSizeStatusNormal && self.comment.cachedCommentTextHeight) {
            sizeForCommentLabel = CGSizeMake((self.frame.size.width - commentRightMargin - commentLeftMargin),
                                             self.comment.cachedCommentTextHeight);
            
        } else if(self.comment.sizeStatus == CommentSizeStatusExpanded && self.comment.cachedCommentExpandedTextHeight) {
            sizeForCommentLabel = CGSizeMake((self.frame.size.width - commentRightMargin - commentLeftMargin),
                                             self.comment.cachedCommentExpandedTextHeight);
            
        } else {
            sizeForCommentLabel = [TTTAttributedLabel sizeThatFitsAttributedString:self.comment.attributedText withConstraints:
                                   CGSizeMake((self.frame.size.width - commentRightMargin - commentLeftMargin), CGFLOAT_MAX) limitedToNumberOfLines:0];
        }
        _commentLabel.frame = CGRectMake(commentLeftMargin, _headerView.frame.origin.y + _headerView.frame.size.height + 10.0f,
                                         (self.frame.size.width - commentRightMargin - commentLeftMargin), sizeForCommentLabel.height);
    }
    _actionDrawerView.frame = CGRectMake(0, self.frame.size.height - kActionDrawerViewHeight, self.frame.size.width, kActionDrawerViewHeight);
    
//    if(self.comment.voteStatus == StoryCommentUserVoteUpvote) {
//        self.upvoteCornerImageView.hidden = NO;
//        self.downvoteCornerImageView.hidden = YES;
//        
//    } else if(self.comment.voteStatus == StoryCommentUserVoteDownvote) {
//        self.downvoteCornerImageView.hidden = NO;
//        self.upvoteCornerImageView.hidden = YES;
//    }
}

- (void)prepareForReuse {
    
    self.commentLabel.text = nil;
    self.headerView.comment = nil;
    
    self.upvoteCornerImageView.hidden = YES;
    self.downvoteCornerImageView.hidden = YES;
}

- (void)didVoteWithType:(StoryCommentUserVote)voteType {
    self.comment.voteStatus = voteType;
    [self setNeedsLayout];
}

+ (void)handleActionForComment:(Comment *)comment withType:(NSNumber *)type inController:(UIViewController *)controller {
    ActionDrawerViewButtonType actionType = [type intValue];
    
    if(actionType == ActionDrawerViewButtonTypeUser) {
        NSLog(@"ActionDrawerViewButtonTypeUser");
        
        [comment loadUserForComment:^(User *user) {
            [controller performSegueWithIdentifier:@"showUser" sender:user];
        }];
        
    } else if(actionType == ActionDrawerViewButtonTypeContext) {
        [controller performSegueWithIdentifier:@"showDetail" sender:comment];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        NSLog(@"ActionDrawerViewButtonTypeMore");
        
        [[self class] createShareActionSheetInController:controller title:
            comment.shareTitle url:comment.hnPublicLink text:nil];
    }
}

+ (void)handleLongPressForLink:(NSURL*)link inComment:(Comment*)comment
                  inController:(UIViewController*)controller {
    
    [[self class] createShareActionSheetInController:controller title:
        link.absoluteString url:link text:nil];
}

+ (CGFloat)heightForCommentCell:(Comment*)comment width:(CGFloat)width {
    
    if(comment.deleted) {
        return 0;
    }
    
    CGFloat heightAccumulator = kCommentCellHeaderViewHeight;
    
    CGSize sizeForCommentLabel = CGSizeZero;
    CGFloat commentRightMargin = 20.f;
    CGFloat commentLeftMargin = 20.f;
    CGFloat commentPadding = 35.0f; // 10.0f top, 25.0f bottom
    
    // Expanded has a flat 20.0f margin, unaffected by indentation
    if(comment.sizeStatus == CommentSizeStatusExpanded) {
        
        if(comment.cachedCommentExpandedTextHeight == -1) {
            
            if(comment && [comment.attributedText length] > 0) {
                sizeForCommentLabel = [TTTAttributedLabel sizeThatFitsAttributedString:comment.attributedText withConstraints:
                                       CGSizeMake((width - commentRightMargin - commentLeftMargin), CGFLOAT_MAX) limitedToNumberOfLines:0];
            }
            comment.cachedCommentExpandedTextHeight = sizeForCommentLabel.height;
            
        } else {
            heightAccumulator += comment.cachedCommentExpandedTextHeight + commentPadding;
        }
        
        
    } else if(comment.sizeStatus == CommentSizeStatusNormal) { // Normal has a margin determined by indentation
        if(comment.cachedCommentTextHeight == -1) {
            
            if(comment && [comment.attributedText length] > 0) {
                
                commentLeftMargin = (20.0f * (comment.indentation + 1));
                sizeForCommentLabel = [TTTAttributedLabel sizeThatFitsAttributedString:comment.attributedText withConstraints:
                                       CGSizeMake((width - commentRightMargin - commentLeftMargin), CGFLOAT_MAX) limitedToNumberOfLines:0];
            }
            comment.cachedCommentTextHeight = sizeForCommentLabel.height;
            
        } else {
            heightAccumulator += comment.cachedCommentTextHeight + commentPadding;
        }
        
    } else {
        
        // Collapsed has no comment size
        if(comment.parentComment.sizeStatus == CommentSizeStatusCollapsed) {
            return 0;
            
        } else {
            return heightAccumulator;
        }
    }

    // Was not retrieved from cache
    if(sizeForCommentLabel.height > 0) {
        heightAccumulator += sizeForCommentLabel.height + commentPadding;
    }
    
    if(comment.sizeStatus == CommentSizeStatusExpanded) {
        heightAccumulator += kActionDrawerViewHeight;
    }
    
    return roundf(heightAccumulator);
}

#pragma mark - Property Override Methods
- (void)setComment:(Comment *)comment {
    _comment = comment;
    
    if(comment.sizeStatus != CommentSizeStatusCollapsed) {
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            if(comment.text != nil) {
                self.commentLabel.text = self.comment.nightAttributedText;
                self.commentLabel.linkAttributes = @{ NSForegroundColorAttributeName: [UIColor orangeColor],
                                                      NSUnderlineStyleAttributeName: @(1) };
            }
        } else {
            if(comment.text != nil) {
                self.commentLabel.text = self.comment.attributedText;
                self.commentLabel.linkAttributes = @{ NSForegroundColorAttributeName: RGBCOLOR(0, 0, 238),
                                                      NSUnderlineStyleAttributeName: @(1) };
            }
        }
    }
    
    self.headerView.comment = comment;
    self.headerView.hidden = NO;
    
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (void)didTapBackgroundView:(id)sender {
    NSLog(@"CommentCell, didTapBackgroundView:");
    
    self.comment.collapseOrigin = YES;
    if(self.comment.sizeStatus == CommentSizeStatusCollapsed) {
        self.comment.sizeStatus = CommentSizeStatusNormal;
        
    } else {
        self.comment.sizeStatus = CommentSizeStatusCollapsed;
    }
}

//- (void)commentCollapsedChanged:(NSNotification*)notification {
//    Comment * comment = notification.object;
//}
+ (void)createShareActionSheetInController:(UIViewController*)controller title:(NSString*)title url:(NSURL*)url text:(NSString*)text {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // Don't double up if the contents are the same
        NSArray *activityItems = nil;
        if([title isEqualToString:url.absoluteString]) {
            activityItems = @[ url ];
            
        } else {
            activityItems = @[ [NSString stringWithFormat:@"%@ - %@", title, url] ];
        }
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        [controller presentViewController:activityVC animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication] openURL:url];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    
    if([[self.comment.linksLookup allKeys] containsObject:url.absoluteString]) {
        NSString * substituteURLString = self.comment.linksLookup[url.absoluteString];
        url = [NSURL URLWithString:substituteURLString];
    }
    
    if([self.commentCellDelegate respondsToSelector:@selector(commentCell:didTapLink:)]) {
        [self.commentCellDelegate performSelector:@selector(commentCell:didTapLink:)
                            withObject:self withObject:url];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label
    didLongPressLinkWithURL:(NSURL *)url
                atPoint:(CGPoint)point {
    
    if([[self.comment.linksLookup allKeys] containsObject:url.absoluteString]) {
        NSString * substituteURLString = self.comment.linksLookup[url.absoluteString];
        url = [NSURL URLWithString:substituteURLString];
    }
    
    if([self.commentCellDelegate respondsToSelector:@selector(commentCell:didLongPressLink:)]) {
        [self.commentCellDelegate performSelector:@selector(commentCell:didLongPressLink:)
                                       withObject:self withObject:url];
    }
}

#pragma mark -StoryActionDrawerViewDelegate Methods
- (void)actionDrawerView:(ActionDrawerView*)view
    didTapActionWithType:(NSNumber*)type {
    
    if([self.commentCellDelegate respondsToSelector:@selector(commentCell:didTapActionWithType:)]) {
        [self.commentCellDelegate performSelector:@selector(commentCell:didTapActionWithType:)
                            withObject:self withObject:type];
    }
}

#pragma mark - Private Methods
- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}

- (void)updateNightMode {
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        UIView * nightSelectedBackgroundView = [[UIView alloc] init];
        nightSelectedBackgroundView.backgroundColor = UIColorFromRGB(0x222222);
        [self setSelectedBackgroundView:nightSelectedBackgroundView];
        
    } else {
        self.selectedBackgroundView = nil;
    }
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.contentView.backgroundColor = kNightDefaultColor;
    } else {
        self.contentView.backgroundColor = UIColorFromRGB(0xffffff);
    }
}


@end
