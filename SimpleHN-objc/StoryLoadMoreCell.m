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
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_loadMoreLabel, _loadMoreSubtitleLabel);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"V:|-[_loadMoreLabel]-4-[_loadMoreSubtitleLabel]-|" options:0 metrics:nil views:bindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-[_loadMoreLabel]-|" options:0 metrics:nil views:bindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"H:|-[_loadMoreSubtitleLabel]-|" options:0 metrics:nil views:bindings]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    _loadingView.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
}

#pragma mark - Property Override Methods
- (void)setState:(StoryLoadMoreCellState)state {
    _state = state;
    
    if(self.state == StoryLoadMoreCellStateNormal) {
        self.loadMoreSubtitleLabel.text = @"Load More";
        
    } else if(self.state == StoryLoadMoreCellStateTransition) {
        self.loadMoreSubtitleLabel.text = @"Keep going...";
        
    } else {
        self.loadMoreSubtitleLabel.text = @"Loading...";
    }
}

@end

