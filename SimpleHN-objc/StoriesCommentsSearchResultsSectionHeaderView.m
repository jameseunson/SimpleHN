//
//  StoriesCommentsSearchResultsSectionHeaderView.m
//  SimpleHN
//
//  Created by James Eunson on 29/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsSearchResultsSectionHeaderView.h"

@interface StoriesCommentsSearchResultsSectionHeaderView ()

@property (nonatomic, strong) UIView * actionLabelTappableAreaView;
- (void)didTapActionLabelArea:(id)sender;

@property (nonatomic, strong, readonly) NSString * titleString;

@end

@implementation StoriesCommentsSearchResultsSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.sectionBackgroundView = [[UIView alloc] init];
        _sectionBackgroundView.backgroundColor = RGBCOLOR(247, 247, 247);
        [self addSubview:_sectionBackgroundView];
        
        self.titleLabel = [[UILabel alloc] init];
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = RGBCOLOR(51, 51, 51);
        
        [self addSubview:self.titleLabel];
        
        self.bottomBorderLayer = [CALayer layer];
        [_bottomBorderLayer setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_bottomBorderLayer];
        
        self.actionLabel = [[UILabel alloc] init];
        
        _actionLabel.textColor = [UIColor orangeColor];
        self.actionLabel.text = @"Adjust Filter";
        self.actionLabel.font = [UIFont systemFontOfSize:16.0f];
        _actionLabel.textAlignment = NSTextAlignmentRight;
        _actionLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_actionLabel];
        
        _loading = YES;
        
        self.filterSubtitleLabel = [[UILabel alloc] init];
        
        _filterSubtitleLabel.textColor = [UIColor grayColor];
        _filterSubtitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _filterSubtitleLabel.backgroundColor = [UIColor clearColor];
        _filterSubtitleLabel.numberOfLines = 1;
        _filterSubtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        [self addSubview:_filterSubtitleLabel];
        
        self.actionLabel.userInteractionEnabled = NO;
        
        self.actionLabelTappableAreaView = [[UIView alloc] init];
        _actionLabelTappableAreaView.backgroundColor = [UIColor clearColor];
        _actionLabelTappableAreaView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:
                                                         self action:@selector(didTapActionLabelArea:)];
        [_actionLabelTappableAreaView addGestureRecognizer:tapGestureRecognizer];
        
        [self addSubview:_actionLabelTappableAreaView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat widthConstraintForTitleLabel = self.frame.size.width - 20;
    
    CGRect rectForActionLabel = CGRectIntegral( [_actionLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : _actionLabel.font } context:nil] );
    
    if(!_actionLabel.hidden) {
        widthConstraintForTitleLabel = self.frame.size.width - 10.0f - 8.0f - rectForActionLabel.size.width; // 10.0f is left inset, 8.0f is padding between label and action label
    }
    
    CGRect rectForTitleLabel = CGRectIntegral( [_titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : _titleLabel.font } context:nil] );
    
    self.sectionBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self.bottomBorderLayer setFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    
    self.actionLabel.frame = CGRectIntegral( CGRectMake(self.frame.size.width - rectForActionLabel.size.width - 10.0f,
                                                        8, rectForActionLabel.size.width, rectForActionLabel.size.height) );
    
    if(!self.actionLabel.hidden) {
        widthConstraintForTitleLabel = self.frame.size.width - 10.0f - 8.0f - self.actionLabel.frame.size.width; // 10.0f is left inset, 8.0f is padding between label and action label
    }
    
    self.titleLabel.frame = CGRectMake(10, 8.0f, rectForTitleLabel.size.width, rectForTitleLabel.size.height);
    
    CGRect rectForFilterSubtitleLabel = CGRectIntegral( [_filterSubtitleLabel.text boundingRectWithSize:CGSizeMake(widthConstraintForTitleLabel, 20.0f) options:
                                                         NSLineBreakByTruncatingTail|NSStringDrawingUsesLineFragmentOrigin attributes:
                                                         @{ NSFontAttributeName : _filterSubtitleLabel.font } context:nil] );
    
    self.filterSubtitleLabel.frame = CGRectMake(10, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height,
                                                rectForFilterSubtitleLabel.size.width, rectForFilterSubtitleLabel.size.height);
    
    CGFloat actionLabelTappableAreaWidth = self.actionLabel.frame.size.width + 10.0f;
    self.actionLabelTappableAreaView.frame = CGRectMake(self.frame.size.width - actionLabelTappableAreaWidth, 0,
                                                        actionLabelTappableAreaWidth, self.frame.size.height);
}

- (void)didTapActionLabelArea:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(storiesCommentsSearchResultsSectionHeaderViewDidTapAdjustFilterButton:)]) {
        [self.delegate performSelector:@selector(storiesCommentsSearchResultsSectionHeaderViewDidTapAdjustFilterButton:)
                            withObject:self];
    }
}

#pragma mark - Property Override Methods
- (NSString*)titleString {
    if(self.loading) {
        return @"Loading results...";
        
    } else {
        
        if(_totalResultsCount > 0) {
            return [NSString stringWithFormat:@"Displaying %lu-%lu of %lu",
                    _currentResultStart, _currentResultEnd, _totalResultsCount];
        } else {
            return @"No results to display";
        }
    }
}

- (void)setTotalResultsCount:(NSInteger)totalResultsCount {
    _totalResultsCount = totalResultsCount;
    
    self.titleLabel.text = self.titleString;
    [self setNeedsLayout];
}

- (void)setCurrentResultStart:(NSInteger)currentResultStart {
    _currentResultStart = currentResultStart;
    
    self.titleLabel.text = self.titleString;
    [self setNeedsLayout];
}

- (void)setCurrentResultEnd:(NSInteger)currentResultEnd {
    _currentResultEnd = currentResultEnd;
    
    self.titleLabel.text = self.titleString;
    [self setNeedsLayout];
}

@end
