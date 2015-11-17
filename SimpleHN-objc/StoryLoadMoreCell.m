//
//  StoryLoadMoreCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 3/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryLoadMoreCell.h"

@implementation StoryLoadMoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        _state = StoryLoadMoreCellStateNormal;
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                            UIActivityIndicatorViewStyleGray];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_loadingView];
        
        self.loadMoreLabel = [[UILabel alloc] init];
        
        _loadMoreLabel.font = [UIFont preferredFontForTextStyle:
                               UIFontTextStyleSubheadline];
        _loadMoreLabel.textColor = [UIColor orangeColor];
        _loadMoreLabel.textAlignment = NSTextAlignmentCenter;
        _loadMoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _loadMoreLabel.text = @"Load More";
        
        [self.contentView addSubview:_loadMoreLabel];
        
        self.loadMoreSubtitleLabel = [[UILabel alloc] init];
        
        _loadMoreSubtitleLabel.font = [UIFont preferredFontForTextStyle:
                                       UIFontTextStyleCaption1];
        _loadMoreSubtitleLabel.textColor = [UIColor lightGrayColor];
        _loadMoreSubtitleLabel.textAlignment = NSTextAlignmentCenter;
        _loadMoreSubtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _loadMoreSubtitleLabel.text = @"Pull down or tap";
        
        [self.contentView addSubview:_loadMoreSubtitleLabel];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_loadMoreLabel, _loadMoreSubtitleLabel, _loadingView);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"V:|-[_loadMoreLabel]-4-[_loadMoreSubtitleLabel]-|" options:0 metrics:nil views:bindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-[_loadMoreLabel]-|" options:0 metrics:nil views:bindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-[_loadMoreSubtitleLabel]-|" options:0 metrics:nil views:bindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:[_loadingView]-|" options:0 metrics:nil views:bindings]];
        
        // Vertically center _loadingView
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma mark - Property Override Methods
- (void)setState:(StoryLoadMoreCellState)state {
    _state = state;
    
    NSLog(@"StoryLoadMoreCell, setState: %lu", self.state);
    
    if(self.state == StoryLoadMoreCellStateNormal) {
        self.loadMoreSubtitleLabel.text = @"Pull down or tap";
        
    } else if(self.state == StoryLoadMoreCellStateTransitionStart) {
        self.loadMoreSubtitleLabel.text = @"Keep going...";
        
    } else if(self.state == StoryLoadMoreCellStateTransitionComplete) {
        self.loadMoreSubtitleLabel.text = @"Release to load";
        
    } else {
        self.loadMoreSubtitleLabel.text = @"Loading...";
    }
    
    if(self.state == StoryLoadMoreCellStateLoading) {
        if(![self.loadingView isAnimating]) {
            [self.loadingView startAnimating];
        }
        
    } else {
        if([self.loadingView isAnimating]) {
            [self.loadingView stopAnimating];
        }
    }
}

@end

