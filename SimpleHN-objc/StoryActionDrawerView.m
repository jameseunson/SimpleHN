//
//  StoryActionDrawerView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryActionDrawerView.h"
#import "StoryActionButton.h"

@interface StoryActionDrawerView ()

@property (nonatomic, strong) UIStackView * actionDrawerContainerView;

@property (nonatomic, strong) StoryActionButton * actionDrawerUserButton;
@property (nonatomic, strong) StoryActionButton * actionDrawerFlagButton;
@property (nonatomic, strong) StoryActionButton * actionDrawerLinkButton;
@property (nonatomic, strong) StoryActionButton * actionDrawerMoreButton;

@property (nonatomic, strong) NSArray < StoryActionButton * > * buttons;

- (void)didTapActionButton:(id)sender;

@end

@implementation StoryActionDrawerView

- (instancetype)init {
    self = [super init];
    if(self) {
        
        self.actionDrawerContainerView = [[UIStackView alloc] init];
        _actionDrawerContainerView.axis = UILayoutConstraintAxisHorizontal;
        _actionDrawerContainerView.alignment = UIStackViewAlignmentCenter;
        _actionDrawerContainerView.distribution = UIStackViewDistributionFillEqually;
        _actionDrawerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.actionDrawerUserButton = [[StoryActionButton alloc] init];
        [_actionDrawerUserButton setImage:[UIImage imageNamed:@"story-action-user-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerUserButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerUserButton];
        
        self.actionDrawerFlagButton = [[StoryActionButton alloc] init];
        [_actionDrawerFlagButton setImage:[UIImage imageNamed:@"story-action-flag-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerFlagButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerFlagButton];
        
        self.actionDrawerLinkButton = [[StoryActionButton alloc] init];
        [_actionDrawerLinkButton setImage:[UIImage imageNamed:@"story-action-link-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerLinkButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerLinkButton];
        
        self.actionDrawerMoreButton = [[StoryActionButton alloc] init];
        [_actionDrawerMoreButton setImage:[UIImage imageNamed:@"story-action-more-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerMoreButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerMoreButton];
        
        [self addSubview:_actionDrawerContainerView];
        
        self.buttons = @[ _actionDrawerUserButton, _actionDrawerFlagButton,
                         _actionDrawerLinkButton, _actionDrawerMoreButton ];
        
        self.buttonTypes = @[@(StoryActionDrawerViewButtonTypeUser),
                             @(StoryActionDrawerViewButtonTypeFlag),
                             @(StoryActionDrawerViewButtonTypeLink),
                             @(StoryActionDrawerViewButtonTypeMore)];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_actionDrawerContainerView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"V:|[_actionDrawerContainerView]|" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"H:|[_actionDrawerContainerView]|" options:0 metrics:nil views:bindings]];
    }
    return self;
}

#pragma mark - Private Methods
- (void)didTapActionButton:(id)sender {
    
    NSInteger indexOfButton = [self.buttons indexOfObject:sender];
    StoryActionDrawerViewButtonType typeForButton = [_buttonTypes[indexOfButton] intValue];
    
    if([self.delegate respondsToSelector:@selector(storyActionDrawerView:didTapActionWithType:)]) {
        [self.delegate performSelector:@selector(storyActionDrawerView:didTapActionWithType:)
                            withObject:self withObject:@(typeForButton)];
    }
}

@end
