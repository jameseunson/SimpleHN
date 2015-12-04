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

@property (nonatomic, strong) ActionDrawerView * actionDrawerView;

- (void)didTapBackgroundView:(id)sender;
//- (void)commentCollapsedChanged:(NSNotification*)notification;

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
        [self.contentView addSubview:_headerView];
        
        self.actionDrawerView = [[ActionDrawerView alloc] init];
        _actionDrawerView.delegate = self;
        _actionDrawerView.hidden = YES;
        [self.contentView addSubview:_actionDrawerView];
        
        self.headerBackgroundViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(didTapBackgroundView:)];
        [self.headerView addGestureRecognizer:_headerBackgroundViewTapGestureRecognizer];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCollapsedChanged:)
//                                                     name:kCommentCollapsedChanged object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _headerView.frame = CGRectMake(0, 0, self.frame.size.width, _headerView.intrinsicContentSize.height);
    
    CGSize sizeForCommentLabel = CGSizeZero;
    
    CGFloat commentRightMargin = 20.f;
    CGFloat commentLeftMargin = 20.f;
    
    if(self.comment && [self.comment.attributedText length] > 0) {
        
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
    }
    
    _commentLabel.frame = CGRectMake(commentLeftMargin, _headerView.frame.origin.y + _headerView.frame.size.height + 10.0f, (self.frame.size.width - commentRightMargin - commentLeftMargin), sizeForCommentLabel.height);
    
    _actionDrawerView.frame = CGRectMake(0, _commentLabel.frame.origin.y + _commentLabel.frame.size.height + 10.0f, self.frame.size.width, _actionDrawerView.intrinsicContentSize.height);
    
    if(_comment.sizeStatus == CommentSizeStatusExpanded) {
        _actionDrawerView.hidden = NO;
        _commentLabel.hidden = NO;
        
        _headerView.collapsed = NO;
        _headerView.hidden = NO;
        
    } else if(_comment.sizeStatus == CommentSizeStatusNormal) {
        _actionDrawerView.hidden = YES;
        _commentLabel.hidden = NO;
        
        _headerView.collapsed = NO;
        _headerView.hidden = NO;
        
    } else if(_comment.sizeStatus == CommentSizeStatusCollapsed) {
        _actionDrawerView.hidden = YES;
        _commentLabel.hidden = YES;
        
        if(self.comment.parentComment.sizeStatus == CommentSizeStatusCollapsed) {
            _headerView.hidden = YES;
        } else {
            _headerView.hidden = NO;
        }
        _headerView.collapsed = YES;
    }
}

- (void)prepareForReuse {

    self.commentLabel.text = nil;
    self.headerView.comment = nil;
}

+ (void)handleActionForComment:(Comment *)comment withType:(NSNumber *)type inController:(UIViewController *)controller {
    ActionDrawerViewButtonType actionType = [type intValue];
    
    if(actionType == ActionDrawerViewButtonTypeUser) {
        NSLog(@"ActionDrawerViewButtonTypeUser");
        
        [comment loadUserForComment:^(User *user) {
            [controller performSegueWithIdentifier:@"showUser" sender:user];
        }];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        NSLog(@"ActionDrawerViewButtonTypeMore");
        
        NSString * title = [NSString stringWithFormat:@"Comment from %@", comment.author];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [controller presentViewController:alertController animated:YES completion:nil];
    }
}

+ (CGFloat)heightForCommentCell:(Comment*)comment width:(CGFloat)width {
    
    CGFloat heightAccumulator = kCommentCellHeaderViewHeight;
    
    CGSize sizeForCommentLabel = CGSizeZero;
    CGFloat commentRightMargin = 20.f;
    CGFloat commentLeftMargin = 20.f;
    
    // Expanded has a flat 20.0f margin, unaffected by indentation
    if(comment.sizeStatus == CommentSizeStatusExpanded) {
        
        if(comment.cachedCommentExpandedTextHeight == -1) {
            
            if(comment && [comment.attributedText length] > 0) {
                sizeForCommentLabel = [TTTAttributedLabel sizeThatFitsAttributedString:comment.attributedText withConstraints:
                                       CGSizeMake((width - commentRightMargin - commentLeftMargin), CGFLOAT_MAX) limitedToNumberOfLines:0];
            }
            comment.cachedCommentExpandedTextHeight = sizeForCommentLabel.height;
            
        } else {
            heightAccumulator += comment.cachedCommentExpandedTextHeight + 20.0f;
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
            heightAccumulator += comment.cachedCommentTextHeight + 20.0f;
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
//        NSLog(@"Calculated height from scratch: %f", sizeForCommentLabel.height);
        heightAccumulator += sizeForCommentLabel.height + 20.0f; // 10pts padding top and bottom
    }
    
    if(comment.sizeStatus == CommentSizeStatusExpanded) {
        heightAccumulator += kActionDrawerViewHeight;
    }
    
    return roundf(heightAccumulator);
}

#pragma mark - Property Override Methods
- (void)setComment:(Comment *)comment {
    _comment = comment;
    
    if(comment.text != nil) {
        self.commentLabel.text = self.comment.attributedText;
    }
    
    self.headerView.comment = comment;
    
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

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    
    if([self.delegate respondsToSelector:@selector(commentCell:didTapLink:)]) {
        [self.delegate performSelector:@selector(commentCell:didTapLink:)
                            withObject:self withObject:url];
    }
}

#pragma mark -StoryActionDrawerViewDelegate Methods
- (void)actionDrawerView:(ActionDrawerView*)view
    didTapActionWithType:(NSNumber*)type {
    
    if([self.delegate respondsToSelector:@selector(commentCell:didTapActionWithType:)]) {
        [self.delegate performSelector:@selector(commentCell:didTapActionWithType:)
                            withObject:self withObject:type];
    }
}

@end
