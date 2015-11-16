//
//  UserHeaderView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "UserHeaderView.h"
#import "KILabel.h"

@interface UserHeaderView ()

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * submissionsLabel;
@property (nonatomic, strong) UILabel * accountCreatedLabel;

@property (nonatomic, strong) UIStackView * mainStackView;

@property (nonatomic, strong) UILabel * karmaLabel;
@property (nonatomic, strong) UILabel * karmaSubtitleLabel;

@property (nonatomic, strong) UIStackView * karmaStackView;

@property (nonatomic, strong) KILabel * aboutLabel;

@property (nonatomic, strong) UIToolbar * toolbar;
@property (nonatomic, strong) UISegmentedControl * sectionSegmentedControl;

- (void)didChangeSegment:(id)sender;

@end

@implementation UserHeaderView

- (instancetype)init {
    self = [super init];
    if(self) {
        
        _visibleData = UserHeaderViewVisibleDataSubmissions;
        
        self.mainStackView = [[UIStackView alloc] init];
        
        _mainStackView.axis = UILayoutConstraintAxisVertical;
        _mainStackView.alignment = UIStackViewAlignmentLeading;
        _mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.nameLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        [_mainStackView addArrangedSubview:_nameLabel];
        
        self.submissionsLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _submissionsLabel.textColor = [UIColor grayColor];
        [_mainStackView addArrangedSubview:_submissionsLabel];
        
        self.accountCreatedLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _accountCreatedLabel.textColor = [UIColor grayColor];
        [_mainStackView addArrangedSubview:_accountCreatedLabel];
        
        [self addSubview:_mainStackView];
        
        self.karmaStackView = [[UIStackView alloc] init];
        
        _karmaStackView.axis = UILayoutConstraintAxisVertical;
        _karmaStackView.alignment = UIStackViewAlignmentLeading;
        _karmaStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.karmaLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        _karmaLabel.textColor = [UIColor orangeColor];
        _karmaLabel.textAlignment = NSTextAlignmentCenter;
        [_karmaStackView addArrangedSubview:_karmaLabel];
        
        self.karmaSubtitleLabel = [LabelHelper labelWithFont:
                           [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _karmaSubtitleLabel.textColor = [UIColor grayColor];
        _karmaSubtitleLabel.text = @"karma";
        _karmaSubtitleLabel.textAlignment = NSTextAlignmentCenter;
        [_karmaStackView addArrangedSubview:_karmaSubtitleLabel];
        
        [self addSubview:_karmaStackView];
        
        self.toolbar = [[UIToolbar alloc] init];
        _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        _toolbar.translucent = YES;
        _toolbar.barTintColor = [UIColor whiteColor];
        _toolbar.tintColor = [UIColor orangeColor];
        
        self.sectionSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"All", @"Submissions", @"Comments" ]];
        _sectionSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        _sectionSegmentedControl.selectedSegmentIndex = 0;
        [_sectionSegmentedControl addTarget:self action:
            @selector(didChangeSegment:) forControlEvents:UIControlEventValueChanged];
        
        [_toolbar addSubview:_sectionSegmentedControl];
        
        [self addSubview:_toolbar];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_mainStackView, _karmaStackView,
                                                                 _toolbar, _sectionSegmentedControl);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"V:|-12-[_mainStackView]" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"V:[_toolbar(44)]-0-|" options:0 metrics:nil views:bindings]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"H:|-12-[_mainStackView]" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"H:|-0-[_toolbar]-0-|" options:0 metrics:nil views:bindings]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"V:|-12-[_karmaStackView]" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"H:[_karmaStackView]-12-|" options:0 metrics:nil views:bindings]];
        
        [self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"V:|-[_sectionSegmentedControl]-|" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"H:|-12-[_sectionSegmentedControl]-12-|" options:0 metrics:nil views:bindings]];

        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_mainStackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.75 constant:0]];
    }
    return self;
}



#pragma mark - Property Override Methods
- (void)setUser:(User *)user {
    _user = user;
    
    self.nameLabel.text = _user.name;
    self.accountCreatedLabel.text = _user.accountCreatedString;
    self.submissionsLabel.text = _user.submissionsString;
    
    self.karmaLabel.text = [_user.karma stringValue];
}

- (void)didChangeSegment:(id)sender {
    NSLog(@"didChangeSegment:");
    
    self.visibleData = (int)self.sectionSegmentedControl.selectedSegmentIndex;
    
    if([self.delegate respondsToSelector:@selector(userHeaderView:didChangeVisibleData:)]) {
        [self.delegate performSelector:@selector(userHeaderView:didChangeVisibleData:)
                            withObject:self withObject:@(_visibleData)];
    }
}

@end
