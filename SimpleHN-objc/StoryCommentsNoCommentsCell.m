//
//  StoryCommentsNoCommentsCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 7/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCommentsNoCommentsCell.h"

@implementation StoryCommentsNoCommentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.emptyView = [[StoryCommentsEmptyView alloc] init];
        _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
        _emptyView.titleLabel.text = @"No comments to display";
        _emptyView.subtitleLabel.text = @"No comments on this article yet.";
        
        [self.contentView addSubview:_emptyView];
        
        [self.contentView addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                                   @"V:|[_emptyView]|;H:|[_emptyView]|" options:0 metrics:nil views:
                                   NSDictionaryOfVariableBindings(_emptyView)]];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
