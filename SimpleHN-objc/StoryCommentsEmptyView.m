//
//  StoryCommentsEmptyView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 7/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCommentsEmptyView.h"

@implementation StoryCommentsEmptyView

- (instancetype)init {
    if(self = [super init]) {
        
        self.backgroundColor = RGBCOLOR(245, 245, 245);
        
        self.stackView = [[UIStackView alloc] init];
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.titleLabel = [LabelHelper labelWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.stackView addArrangedSubview:_titleLabel];
        
        self.subtitleLabel = [LabelHelper labelWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.stackView addArrangedSubview:_subtitleLabel];
        [self addSubview:_stackView];
        
        [self addConstraint:[self.centerXAnchor constraintEqualToAnchor:
                                          _stackView.centerXAnchor]];
        [self addConstraint:[self.centerYAnchor constraintEqualToAnchor:
                                          _stackView.centerYAnchor]];
        
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            
            self.backgroundColor = UIColorFromRGB(0xffffff);
            self.nightBackgroundColor = kNightDefaultColor;
        }];
        
    }
    return self;
}

@end
