//
//  StoryActionDrawerView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "ActionDrawerView.h"
#import "ActionDrawerButton.h"

@interface ActionDrawerView ()

@property (nonatomic, strong) UIStackView * actionDrawerContainerView;

@property (nonatomic, strong) ActionDrawerButton * actionDrawerUserButton;
@property (nonatomic, strong) ActionDrawerButton * actionDrawerFlagButton;
@property (nonatomic, strong) ActionDrawerButton * actionDrawerLinkButton;
@property (nonatomic, strong) ActionDrawerButton * actionDrawerMoreButton;

@property (nonatomic, strong) NSArray < ActionDrawerButton * > * buttons;

- (void)didTapActionButton:(id)sender;

@end

@implementation ActionDrawerView

- (instancetype)init {
    self = [super init];
    if(self) {
        
        self.actionDrawerContainerView = [[UIStackView alloc] init];
        _actionDrawerContainerView.axis = UILayoutConstraintAxisHorizontal;
        _actionDrawerContainerView.alignment = UIStackViewAlignmentCenter;
        _actionDrawerContainerView.distribution = UIStackViewDistributionFillEqually;
        _actionDrawerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.actionDrawerUserButton = [[ActionDrawerButton alloc] init];
        [_actionDrawerUserButton setImage:[UIImage imageNamed:@"story-action-user-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerUserButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerUserButton];
        
        self.actionDrawerFlagButton = [[ActionDrawerButton alloc] init];
        [_actionDrawerFlagButton setImage:[UIImage imageNamed:@"story-action-flag-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerFlagButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerFlagButton];
        
        self.actionDrawerLinkButton = [[ActionDrawerButton alloc] init];
        [_actionDrawerLinkButton setImage:[UIImage imageNamed:@"story-action-link-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerLinkButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerLinkButton];
        
        self.actionDrawerMoreButton = [[ActionDrawerButton alloc] init];
        [_actionDrawerMoreButton setImage:[UIImage imageNamed:@"story-action-more-icon"]
                                 forState:UIControlStateNormal];
        [_actionDrawerMoreButton addTarget:self action:@selector(didTapActionButton:)
                          forControlEvents:UIControlEventTouchUpInside];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerMoreButton];
        
        [self addSubview:_actionDrawerContainerView];
        
        self.buttons = @[ _actionDrawerUserButton, _actionDrawerFlagButton,
                         _actionDrawerLinkButton, _actionDrawerMoreButton ];
        
        self.buttonTypes = @[@(ActionDrawerViewButtonTypeUser),
                             @(ActionDrawerViewButtonTypeFlag),
                             @(ActionDrawerViewButtonTypeLink),
                             @(ActionDrawerViewButtonTypeMore)];
        
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
    ActionDrawerViewButtonType typeForButton = [_buttonTypes[indexOfButton] intValue];
    
    if([self.delegate respondsToSelector:@selector(actionDrawerView:didTapActionWithType:)]) {
        [self.delegate performSelector:@selector(actionDrawerView:didTapActionWithType:)
                            withObject:self withObject:@(typeForButton)];
    }
}

@end
