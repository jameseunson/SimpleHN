//
//  StoryCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCell.h"
#import "NSDate+TimeAgo.h"

#import "StoryCommentsButton.h"

@interface StoryCell ()

@property (nonatomic, strong) UILabel * storyTitleLabel;
@property (nonatomic, strong) UILabel * storySubtitleLabel;
@property (nonatomic, strong) UIStackView * storyTitleSubtitleStackView;

@property (nonatomic, strong) StoryCommentsButton * storyCommentsButton;
@property (nonatomic, strong) UILabel * storyScoreLabel;
@property (nonatomic, strong) UIStackView * storyCommentsScoreStackView;

@end

@implementation StoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.storyTitleSubtitleStackView = [[UIStackView alloc] init];
        
        _storyTitleSubtitleStackView.axis = UILayoutConstraintAxisVertical;
        _storyTitleSubtitleStackView.alignment = UIStackViewAlignmentLeading;
        _storyTitleSubtitleStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.storyTitleLabel = [[UILabel alloc] init];
        
        _storyTitleLabel.font = [UIFont systemFontOfSize:17.0f];
        _storyTitleLabel.backgroundColor = [UIColor clearColor];
        _storyTitleLabel.numberOfLines = 0;
        _storyTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _storyTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.storyTitleSubtitleStackView addArrangedSubview:_storyTitleLabel];
        
        self.storySubtitleLabel = [[UILabel alloc] init];
        
        _storySubtitleLabel.font = [UIFont systemFontOfSize:12.0f];
        _storySubtitleLabel.textColor = [UIColor grayColor];
        _storySubtitleLabel.backgroundColor = [UIColor clearColor];
        _storySubtitleLabel.numberOfLines = 0;
        _storySubtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _storySubtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.storyTitleSubtitleStackView addArrangedSubview:_storySubtitleLabel];
        [self addSubview:_storyTitleSubtitleStackView];
        
        self.storyCommentsScoreStackView = [[UIStackView alloc] init];

        _storyCommentsScoreStackView.axis = UILayoutConstraintAxisVertical;
        _storyCommentsScoreStackView.distribution = UIStackViewDistributionFill;
        _storyCommentsScoreStackView.alignment = UIStackViewAlignmentCenter;
        _storyCommentsScoreStackView.spacing = 30;
        _storyCommentsScoreStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        self.storyCommentsButton = [[StoryCommentsButton alloc] init];
        _storyCommentsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_storyCommentsScoreStackView addArrangedSubview:_storyCommentsButton];
        
        self.storyScoreLabel = [[UILabel alloc] init];
        _storyScoreLabel.font = [UIFont systemFontOfSize:11.0f];
        _storyScoreLabel.textColor = [UIColor orangeColor];
        [_storyCommentsScoreStackView addArrangedSubview:_storyScoreLabel];
        
        [self addSubview:_storyCommentsScoreStackView];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_storyTitleSubtitleStackView,
                                                                 _storyCommentsScoreStackView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_storyTitleSubtitleStackView]-|"
                                                                     options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_storyCommentsScoreStackView]-|"
                                                                     options:0 metrics:nil views:bindings]];
        
//        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_storyTitleSubtitleStackView]-[_storyCommentsScoreStackView]-|"
//                                                                                                      options:0 metrics:nil views:bindings];
//        [self addConstraints:constraints];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_storyTitleSubtitleStackView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeadingMargin multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_storyTitleSubtitleStackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.75 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_storyCommentsScoreStackView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_storyCommentsScoreStackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.15 constant:0]];
    }
    return self;
}

#pragma mark - Property Override Methods
- (void)setStory:(Story *)story {
    _story = story;
    
    self.storyTitleLabel.text = story.title;
    self.storySubtitleLabel.text = [NSString stringWithFormat:@"%@ · %@ · %@",
                                 story.url.host, story.author, story.time];
    self.storyCommentsButton.story = story;
    
    _storyScoreLabel.text = [story.score stringValue];
    [_storyScoreLabel sizeToFit];

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

@end
