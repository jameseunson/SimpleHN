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
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                            UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_loadingView];
        
        self.loadMoreLabel = [[UILabel alloc] init];
        
        _loadMoreLabel.font = [UIFont systemFontOfSize:16.0f];
        _loadMoreLabel.textColor = [UIColor orangeColor];
        _loadMoreLabel.textAlignment = NSTextAlignmentCenter;
        _loadMoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _loadMoreLabel.text = @"Load More";
        
        [self.contentView addSubview:_loadMoreLabel];
        
        self.loadMoreSubtitleLabel = [[UILabel alloc] init];
        
        _loadMoreSubtitleLabel.font = [UIFont systemFontOfSize:11.0f];
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

@end

