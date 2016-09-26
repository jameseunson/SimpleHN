//
//  UserEmptyView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 16/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "UserEmptyView.h"
#import "JBNSLayoutConstraint+LinearEquation.h"
#import "UserLoginButton.h"

@interface UserEmptyView ()

@property (nonatomic, strong) UIStackView * stackView;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;

@property (nonatomic, strong) UserLoginButton * loginButton;

- (void)didTapActionButton:(id)sender;

@end

@implementation UserEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = RGBCOLOR(238, 238, 238);
        
        self.stackView = [[UIStackView alloc] init];
        
        _stackView.translatesAutoresizingMaskIntoConstraints = NO;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.distribution = UIStackViewDistributionEqualCentering;
        _stackView.spacing = 10.0f;
        
        self.titleLabel = [LabelHelper labelWithFont:[UIFont systemFontOfSize:24.0f]
                                               color:[UIColor blackColor] alignment:NSTextAlignmentCenter];
        _titleLabel.text = @"Not logged in";
        [self.stackView addArrangedSubview:_titleLabel];
        
        self.subtitleLabel = [LabelHelper labelWithFont:[UIFont systemFontOfSize:14.0f]
                                                  color:[UIColor darkGrayColor] alignment:NSTextAlignmentCenter];
        _subtitleLabel.text = @"Login with your Hacker News account to vote, post comments, flag submissions and more.";
        [self.stackView addArrangedSubview:_subtitleLabel];
        
        self.loginButton = [[UserLoginButton alloc] init];
        _loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_loginButton addTarget:self action:@selector(didTapActionButton:)
                forControlEvents:UIControlEventTouchUpInside];
        [_stackView addArrangedSubview:_loginButton];
        
        [self addSubview:_stackView];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_titleLabel, _subtitleLabel, _loginButton);
        
        [_stackView addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                                    @"H:|-20-[_titleLabel]-20-|;H:|-20-[_subtitleLabel]-20-|;H:|-20-[_loginButton]-20-|;V:[_loginButton(44)]" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                              @"H:|[_stackView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stackView)]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_stackView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    return self;
}

- (void)updateNightMode {
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.backgroundColor = RGBCOLOR(0, 0, 0);
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.textColor = [UIColor grayColor];
        
    } else {
        
        self.backgroundColor = RGBCOLOR(238, 238, 238);
        
        self.titleLabel.textColor = [UIColor blackColor];
        self.subtitleLabel.textColor = [UIColor darkGrayColor];
    }
}


#pragma mark - Private Methods
- (void)didTapActionButton:(id)sender {
    NSLog(@"didTapActionButton:");
    
    if([self.delegate respondsToSelector:@selector(userEmptyView:didTapLoginButton:)]) {
        [self.delegate performSelector:@selector(userEmptyView:didTapLoginButton:)
                            withObject:self withObject:sender];
    }
}

@end
