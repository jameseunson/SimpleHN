//
//  ContentLoadingView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "ContentLoadingView.h"
#import "UIFont+SSTextSize.h"

// UIStackView means I don't even have to write a
// layoutSubviews method!

@interface ContentLoadingView ()

@property (nonatomic, strong) UIStackView * stackView;

@property (nonatomic, strong) UILabel * loadingLabel;
@property (nonatomic, strong) UIActivityIndicatorView * loadingView;

@end

@implementation ContentLoadingView

- (instancetype)init {
    self = [super init];
    if(self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.stackView = [[UIStackView alloc] init];
        
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.translatesAutoresizingMaskIntoConstraints = NO;
        _stackView.spacing = 8.0f;
        
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                            UIActivityIndicatorViewStyleGray];
        [_loadingView startAnimating];        
        [_loadingView sizeToFit];
        [self.stackView addArrangedSubview:_loadingView];
        
        NSString * systemFontName = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontName];
        self.loadingLabel = [LabelHelper labelWithFont:[UIFont dynamicFontWithName:systemFontName baseSize:16.0f]];
        
        _loadingLabel.textColor = RGBCOLOR(102, 102, 102);
        _loadingLabel.text = @"Loading...";
        _loadingLabel.numberOfLines = 1;
        [_loadingLabel sizeToFit];
        
        [self.stackView addArrangedSubview:_loadingLabel];
        
        [self addSubview:_stackView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_stackView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_stackView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }
    return self;
}

@end
