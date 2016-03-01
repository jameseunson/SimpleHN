//
//  StoryLoadingMoreCommentsCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 1/03/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "StoryLoadingMoreCommentsCell.h"

@implementation StoryLoadingMoreCommentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                            UIActivityIndicatorViewStyleGray];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_loadingView];
        
        self.loadMoreLabel = [[UILabel alloc] init];
        
        _loadMoreLabel.font = [UIFont preferredFontForTextStyle:
                               UIFontTextStyleSubheadline];
        _loadMoreLabel.textColor = [UIColor grayColor];
        _loadMoreLabel.textAlignment = NSTextAlignmentCenter;
        _loadMoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _loadMoreLabel.text = @"Loading more comments";
        
        [self.contentView addSubview:_loadMoreLabel];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_loadMoreLabel, _loadingView);
        
        [self.contentView addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                                          @"V:|-[_loadMoreLabel]-|;H:|-[_loadMoreLabel]-|;H:[_loadingView]-|" options:0 metrics:nil views:bindings]];
        // Vertically center _loadingView
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            self.contentView.normalBackgroundColor = UIColorFromRGB(0xffffff);
            self.contentView.nightBackgroundColor = kNightDefaultColor;
        }];
    }
    return self;
}

@end
