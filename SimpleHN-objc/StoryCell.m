//
//  StoryCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCell.h"
#import "StoryCommentsButton.h"
#import "ActionDrawerButton.h"
#import "TimeAgoInWords-Swift.h"
#import "TTTAttributedLabel.h"
#import "ProgressHUDHelper.h"

@interface StoryCell ()

@property (nonatomic, strong) UILabel * storyTitleLabel;
@property (nonatomic, strong) UILabel * storySubtitleLabel;

@property (nonatomic, strong) StoryCommentsButton * storyCommentsButton;
@property (nonatomic, strong) UIImageView * storyScoreIconImageView;
@property (nonatomic, strong) UILabel * storyScoreLabel;

// Tappable area for comments, includes score, comments and some extra horizontal space
@property (nonatomic, strong) UIView * storyCommentsAreaView;

// Used for Ask HN and Show HN posts
@property (nonatomic, strong) TTTAttributedLabel * storyAboutLabel;

@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGestureRecognizer;

@property (nonatomic, strong) ActionDrawerView * actionDrawerView;

- (void)didLongPressSelf:(id)sender;
- (void)didTapStoryCommentsAreaView:(id)sender;

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

@end

@implementation StoryCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
        _contextType = StoryCellContextTypeList;
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(didLongPressSelf:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.6;
        [self addGestureRecognizer:_longPressGestureRecognizer];
        
        self.storyTitleLabel = [LabelHelper labelWithFont:
                                [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        [self.contentView addSubview:_storyTitleLabel];
        
        self.storySubtitleLabel = [LabelHelper labelWithFont:
                                   [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _storySubtitleLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_storySubtitleLabel];
        
        self.storyCommentsButton = [[StoryCommentsButton alloc] init];
        _storyCommentsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_storyCommentsButton];
        
        self.storyScoreIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"story-cell-upvote-small-icon"]];
        [self.contentView addSubview:_storyScoreIconImageView];
        
        self.storyScoreLabel = [[UILabel alloc] init];
        _storyScoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _storyScoreLabel.textColor = [UIColor orangeColor];
        _storyScoreLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_storyScoreLabel];
        
        self.storyAboutLabel = [LabelHelper tttLabelWithFont:
                                [UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        _storyAboutLabel.hidden = YES;
        _storyAboutLabel.delegate = self;
        [self.contentView addSubview:_storyAboutLabel];

        self.actionDrawerView = [[ActionDrawerView alloc] init];
        _actionDrawerView.delegate = self;
        _actionDrawerView.hidden = YES;
        [self.contentView addSubview:_actionDrawerView];
        
        self.storyCommentsAreaView = [[UIView alloc] init];
        _storyCommentsAreaView.userInteractionEnabled = YES;
        _storyCommentsAreaView.backgroundColor = [UIColor clearColor];
        [_storyCommentsAreaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:
                                                      self action:@selector(didTapStoryCommentsAreaView:)]];
        [self.contentView addSubview:_storyCommentsAreaView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionNightFallingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionDawnComingNotification object:nil];
        
        [self updateNightMode];
    }
    return self;
}

- (void)prepareForReuse {
    _story = nil;
    
    _storyTitleLabel.text = nil;
    _storySubtitleLabel.text = nil;
    
    _storyCommentsButton.story = nil;
    _storyScoreLabel.text = nil;
    
    _storyAboutLabel.text = nil;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 20pts padding either side
    CGFloat horizontalMargin = 20.0f;
    CGFloat widthConstraintForTitleSubtitle = roundf(self.frame.size.width * 0.80f) - (horizontalMargin * 2);
    
    CGRect boundingRectForTitleLabel = [self.storyTitleLabel.text boundingRectWithSize:CGSizeMake(widthConstraintForTitleSubtitle, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: self.storyTitleLabel.font } context:nil];
    self.storyTitleLabel.frame = CGRectIntegral( CGRectMake(horizontalMargin, 10.0f, widthConstraintForTitleSubtitle, boundingRectForTitleLabel.size.height) );
    
    CGRect boundingRectForSubtitleLabel = [self.storySubtitleLabel.text boundingRectWithSize:CGSizeMake(widthConstraintForTitleSubtitle, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: self.storySubtitleLabel.font } context:nil];
    self.storySubtitleLabel.frame = CGRectIntegral( CGRectMake(horizontalMargin, _storyTitleLabel.frame.origin.y + _storyTitleLabel.frame.size.height, widthConstraintForTitleSubtitle, boundingRectForSubtitleLabel.size.height) );
    
    self.storyCommentsButton.frame = CGRectIntegral( CGRectMake(self.frame.size.width - kCommentsButtonWidth - horizontalMargin,
                                                                10.0f, kCommentsButtonWidth, kCommentsButtonHeight) );
    
    _storyScoreIconImageView.frame = CGRectMake(_storyCommentsButton.frame.origin.x, _storyCommentsButton.frame.origin.y + _storyCommentsButton.frame.size.height + 11.0f, _storyScoreIconImageView.frame.size.width, _storyScoreIconImageView.frame.size.height);
    
    CGSize sizeForScoreLabel = [_storyScoreLabel.text sizeWithAttributes:@{ NSFontAttributeName: _storyScoreLabel.font }];
    self.storyScoreLabel.frame = CGRectIntegral( CGRectMake(_storyScoreIconImageView.frame.origin.x + _storyScoreIconImageView.frame.size.width + 2.0f, _storyCommentsButton.frame.origin.y + _storyCommentsButton.frame.size.height + 8.0f, sizeForScoreLabel.width, sizeForScoreLabel.height) );
    
    if(_story.sizeStatus == StorySizeStatusExpanded) {
        
        _actionDrawerView.hidden = NO;
        if(self.contextType == StoryCellContextTypeDetail) {
            _actionDrawerView.contextType = ActionDrawerViewContextTypeDetail;
            
        } else if(self.contextType == StoryCellContextTypeList) {
            _actionDrawerView.contextType = ActionDrawerViewContextTypeList;
        }
        
        // Ensure Ask HN text only displays in 'Detail' context, not 'List' context
        if(_story.text && _contextType == StoryCellContextTypeDetail) {
            
            CGFloat heightForTitleSubtitle = roundf(10.0f + boundingRectForSubtitleLabel.size.height + boundingRectForTitleLabel.size.height + 20.0f);
            CGFloat heightForScoreComments = roundf(10.0f + sizeForScoreLabel.height + 8.0f + kCommentsButtonHeight + 10.0f);
            
            CGFloat startPointForAboutLabel = MAX(heightForScoreComments, heightForTitleSubtitle);
            
            CGSize sizeForAboutLabel = [TTTAttributedLabel sizeThatFitsAttributedString:self.story.attributedText withConstraints:
                                                CGSizeMake((self.frame.size.width - (horizontalMargin * 2)), CGFLOAT_MAX) limitedToNumberOfLines:0];
            self.storyAboutLabel.frame = CGRectIntegral( CGRectMake(horizontalMargin, startPointForAboutLabel, self.frame.size.width - (horizontalMargin * 2), sizeForAboutLabel.height) );
        }
        
    } else if(_story.sizeStatus == StorySizeStatusNormal) {
        _actionDrawerView.hidden = YES;
    }
    
    if(self.story.voteStatus == StoryCommentUserVoteUpvote) {
        self.upvoteCornerImageView.hidden = NO;
        self.downvoteCornerImageView.hidden = YES;
        
    } else if(self.story.voteStatus == StoryCommentUserVoteDownvote) {
        self.downvoteCornerImageView.hidden = NO;
        self.upvoteCornerImageView.hidden = YES;
    }
    
    CGFloat storyCommentsAreaViewWidth = roundf(self.frame.size.width / 4);
    
    if(_contextType == StoryCellContextTypeList) {
        
        CGFloat storyCommentsAreaViewHeight = self.frame.size.height;
        if(_story.sizeStatus == StorySizeStatusExpanded) {
            storyCommentsAreaViewHeight = self.frame.size.height -_actionDrawerView.frame.size.height;
        }
        
        _storyCommentsAreaView.frame = CGRectMake(self.frame.size.width - storyCommentsAreaViewWidth,
                                                  0, storyCommentsAreaViewWidth, storyCommentsAreaViewHeight);
        _storyCommentsAreaView.hidden = NO;
        
    } else {
        _storyCommentsAreaView.frame = CGRectZero;
        _storyCommentsAreaView.hidden = YES;
    }
    
    _actionDrawerView.frame = CGRectMake(0, self.frame.size.height - kActionDrawerViewHeight, self.frame.size.width, kActionDrawerViewHeight);
}

+ (void)handleActionForStory:(Story*)story withType:
    (NSNumber*)type inController:(UIViewController*)controller {
    
    ActionDrawerViewButtonType actionType = [type intValue];
    
    if(actionType == ActionDrawerViewButtonTypeUser) {
        [controller performSegueWithIdentifier:@"showUser" sender:story.author];
        
    } else if(actionType == ActionDrawerViewButtonTypeShare) {
        NSArray *activityItems = @[ [NSString stringWithFormat:@"%@ - %@", story.title, story.url] ];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        [controller presentViewController:activityVC animated:YES completion:nil];
    
    } else if(actionType == ActionDrawerViewButtonTypeLink) {
        
        [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"tick"]
                                          withLabelText:@"Link Copied" withDetailsLabelText:nil];
        
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[story.hnPublicLink absoluteString]];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:story.title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:story.url];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [controller presentViewController:alertController animated:YES completion:nil];
    }
}

+ (CGFloat)heightForStoryCellWithStory:(Story*)story width:(CGFloat)width {
    return [[self class] heightForStoryCellWithStory:story width:width context:StoryCellContextTypeList];
}

+ (CGFloat)heightForStoryCellWithStory:(Story*)story width:(CGFloat)width context:(StoryCellContextType)contextType {
    
    // 20pts padding either side
    CGFloat horizontalMargin = 20.0f;
    CGFloat widthConstraintForTitleSubtitle = roundf(width * 0.80f) - (horizontalMargin * 2);
    
    // Calculate title + subtitle height
    CGRect boundingRectForTitleLabel = [story.title boundingRectWithSize:CGSizeMake(widthConstraintForTitleSubtitle, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3] } context:nil];
    
    CGRect boundingRectForSubtitleLabel = [story.subtitleString boundingRectWithSize:CGSizeMake(widthConstraintForTitleSubtitle, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1] } context:nil];
    
    CGFloat heightForTitleSubtitle = roundf(10.0f + boundingRectForSubtitleLabel.size.height + boundingRectForTitleLabel.size.height + 20.0f);
    
    // Calculate score + comments height
    CGSize sizeForScoreLabel = [[story.score stringValue] sizeWithAttributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2] }];
    
    CGFloat heightForScoreComments = roundf(10.0f + sizeForScoreLabel.height + 8.0f + kCommentsButtonHeight + 10.0f);
    
    // Pick whichever one is larger
    CGFloat contentHeight = MAX(heightForScoreComments, heightForTitleSubtitle);
    
    if(story.sizeStatus == StorySizeStatusExpanded) {
        
        if(story.text && contextType == StoryCellContextTypeDetail) {
            CGSize sizeForAboutLabel = [TTTAttributedLabel sizeThatFitsAttributedString:story.attributedText withConstraints:
                                        CGSizeMake((width - (horizontalMargin * 2)), CGFLOAT_MAX) limitedToNumberOfLines:0];
            contentHeight += roundf(sizeForAboutLabel.height + 10.0f + 20.0f); // 10pts top, 20pts bottom
        }
        
        contentHeight += kActionDrawerViewHeight;
    }
    return contentHeight;
}

- (void)didVoteWithType:(StoryCommentUserVote)voteType {
    self.story.voteStatus = voteType;
    [self setNeedsLayout];
}

#pragma mark - Property Override Methods
- (void)setStory:(Story *)story {
    _story = story;
    
    self.storyTitleLabel.text = story.title;
    [_storyTitleLabel sizeToFit];
    
    self.storySubtitleLabel.text = story.subtitleString;
    [_storySubtitleLabel sizeToFit];
    
    self.storyCommentsButton.story = story;
    
    _storyScoreLabel.text = [story.score stringValue];
    [_storyScoreLabel sizeToFit];
    
    if(story.text) {
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            if(story.text != nil) {
                self.storyAboutLabel.text = self.story.nightAttributedText;
                self.storyAboutLabel.linkAttributes = @{ NSForegroundColorAttributeName: [UIColor orangeColor],
                                                      NSUnderlineStyleAttributeName: @(1) };
            }
        } else {
            if(story.text != nil) {
                self.storyAboutLabel.text = self.story.attributedText;
                self.storyAboutLabel.linkAttributes = @{ NSForegroundColorAttributeName: RGBCOLOR(0, 0, 238),
                                                      NSUnderlineStyleAttributeName: @(1) };
            }
        }
        _storyAboutLabel.hidden = NO;
        
    } else {
        _storyAboutLabel.hidden = YES;
    }
    
    if(story.url) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    [self setNeedsUpdateConstraints];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (void)didLongPressSelf:(id)sender {
    NSLog(@"didLongPressSelf:");
    
    if (self.longPressGestureRecognizer.state == UIGestureRecognizerStateBegan){
        if([self.storyCellDelegate respondsToSelector:@selector(storyCellDidDisplayActionDrawer:)]) {
            [self.storyCellDelegate performSelector:@selector(storyCellDidDisplayActionDrawer:) withObject:self];
        }
    }
}

- (void)didTapStoryCommentsAreaView:(id)sender {
    
    UILongPressGestureRecognizer * recognizer = (UILongPressGestureRecognizer*)sender;
    NSLog(@"UILongPressGestureRecognizer.state = %lu", recognizer.state);
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        self.storyCommentsButton.tapFeedbackViewVisible = YES;
        
    } else if(recognizer.state == UIGestureRecognizerStateEnded) {
        self.storyCommentsButton.tapFeedbackViewVisible = NO;
        
        if([self.storyCellDelegate respondsToSelector:@selector(storyCellDidTapCommentsArea:)]) {
            [self.storyCellDelegate performSelector:@selector(storyCellDidTapCommentsArea:) withObject:self];
        }
    }
}

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
        self.storyTitleLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = kNightDefaultColor;
        
        self.contentView.backgroundColor = nil;
        
    } else {
        
        self.storyTitleLabel.textColor = [UIColor blackColor];
        self.backgroundColor = UIColorFromRGB(0xffffff);
        
        self.contentView.backgroundColor = nil;
    }
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    
    if([[self.story.linksLookup allKeys] containsObject:url.absoluteString]) {
        NSString * substituteURLString = self.story.linksLookup[url.absoluteString];
        url = [NSURL URLWithString:substituteURLString];
    }
    
    if([self.storyCellDelegate respondsToSelector:@selector(storyCell:didTapLink:)]) {
        [self.storyCellDelegate performSelector:@selector(storyCell:didTapLink:)
                                     withObject:self withObject:url];
    }
}

#pragma mark -StoryActionDrawerViewDelegate Methods
- (void)actionDrawerView:(ActionDrawerView*)view
         didTapActionWithType:(NSNumber*)type {
    
    if([self.storyCellDelegate respondsToSelector:@selector(storyCell:didTapActionWithType:)]) {
        [self.storyCellDelegate performSelector:@selector(storyCell:didTapActionWithType:)
                            withObject:self withObject:type];
    }
}

@end
