//
//  StoryCommentsContentLoadingCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 14/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCommentsContentLoadingCell.h"

@implementation StoryCommentsContentLoadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.loadingView = [[ContentLoadingView alloc] init];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_loadingView];
        
        [self.contentView addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:@"H:|[_loadingView]|;V:|[_loadingView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_loadingView)]];
    }
    return self;
}

@end
