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

@interface StoryCell ()

@property (nonatomic, strong) UILabel * storyTitleLabel;
@property (nonatomic, strong) UILabel * storySubtitleLabel;

@property (nonatomic, strong) StoryCommentsButton * storyCommentsButton;
@property (nonatomic, strong) UILabel * storyScoreLabel;

// Used for Ask HN and Show HN posts
@property (nonatomic, strong) TTTAttributedLabel * storyAboutLabel;

@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGestureRecognizer;

@property (nonatomic, strong) ActionDrawerView * actionDrawerView;

- (void)didLongPressSelf:(id)sender;

@end

@implementation StoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
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
        
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            self.normalBackgroundColor = UIColorFromRGB(0xffffff);
            self.nightBackgroundColor = UIColorFromRGB(0x333333);
            
            self.storyTitleLabel.normalTextColor = [UIColor blackColor];
            self.storyTitleLabel.nightTextColor = UIColorFromRGB(0x999999);
        }];
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
    
    CGSize sizeForScoreLabel = [_storyScoreLabel.text sizeWithAttributes:@{ NSFontAttributeName: _storyScoreLabel.font }];
    self.storyScoreLabel.frame = CGRectIntegral( CGRectMake(_storyCommentsButton.frame.origin.x, _storyCommentsButton.frame.origin.y + _storyCommentsButton.frame.size.height + 8.0f, _storyCommentsButton.frame.size.width, sizeForScoreLabel.height) );
    
    if(_story.sizeStatus == StorySizeStatusExpanded) {
        _actionDrawerView.hidden = NO;
        
        if(_story.text) {
            
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
    
    _actionDrawerView.frame = CGRectMake(0, self.frame.size.height - kActionDrawerViewHeight, self.frame.size.width, kActionDrawerViewHeight);
}

+ (void)handleActionForStory:(Story*)story withType:
    (NSNumber*)type inController:(UIViewController*)controller {
    
    ActionDrawerViewButtonType actionType = [type intValue];
    
    if(actionType == ActionDrawerViewButtonTypeUser) {
        [controller performSegueWithIdentifier:@"showUser" sender:story.author];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:story.title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSArray *activityItems = @[ [NSString stringWithFormat:@"%@ - %@", story.title, story.url] ];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
            [controller presentViewController:activityVC animated:YES completion:nil];
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:story.url];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [controller presentViewController:alertController animated:YES completion:nil];
    }
}

+ (CGFloat)heightForStoryCellWithStory:(Story*)story width:(CGFloat)width {
    
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
        
        if(story.text) {
            CGSize sizeForAboutLabel = [TTTAttributedLabel sizeThatFitsAttributedString:story.attributedText withConstraints:
                                        CGSizeMake((width - (horizontalMargin * 2)), CGFLOAT_MAX) limitedToNumberOfLines:0];
            contentHeight += roundf(sizeForAboutLabel.height + 10.0f + 20.0f); // 10pts top, 20pts bottom
        }
        
        contentHeight += kActionDrawerViewHeight;
    }
    return contentHeight;
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
        _storyAboutLabel.text = story.attributedText;
        _storyAboutLabel.hidden = NO;
        
    } else {
        _storyAboutLabel.hidden = YES;
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

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    
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
