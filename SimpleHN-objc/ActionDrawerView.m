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

@property (nonatomic, strong) CALayer * actionDrawerBorderLayer;

- (void)didTapActionButton:(id)sender;
- (ActionDrawerButton*)createButtonWithType:(ActionDrawerViewButtonType)type;

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
        
        self.actionDrawerUserButton = [self createButtonWithType:ActionDrawerViewButtonTypeUser];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerUserButton];
        
        self.actionDrawerFlagButton = [self createButtonWithType:ActionDrawerViewButtonTypeFlag];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerFlagButton];
        
        self.actionDrawerLinkButton = [self createButtonWithType:ActionDrawerViewButtonTypeLink];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerLinkButton];
        
        self.actionDrawerMoreButton = [self createButtonWithType:ActionDrawerViewButtonTypeMore];
        [_actionDrawerContainerView addArrangedSubview:_actionDrawerMoreButton];
        
        [self addSubview:_actionDrawerContainerView];
        
        self.buttons = @[ _actionDrawerUserButton, _actionDrawerFlagButton,
                         _actionDrawerLinkButton, _actionDrawerMoreButton ];
        
        self.actionDrawerBorderLayer = [CALayer layer];
        _actionDrawerBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_actionDrawerBorderLayer atIndex:100];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_actionDrawerContainerView);
        
        [self addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                              @"V:|-10-[_actionDrawerContainerView];H:|-0-[_actionDrawerContainerView]-0-|"
                                                                        options:0 metrics:nil views:bindings]];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, _actionDrawerContainerView
                        .intrinsicContentSize.height + 20.0f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _actionDrawerBorderLayer.frame = CGRectMake(0, 0, self.frame.size.width, (1.0f / [[UIScreen mainScreen] scale]));
}

#pragma mark - Private Methods
- (ActionDrawerButton*)createButtonWithType:(ActionDrawerViewButtonType)type {
    
    ActionDrawerButton * button = [ActionDrawerButton buttonWithType:type];
    [button addTarget:self action:@selector(didTapActionButton:)
                      forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)didTapActionButton:(id)sender {
    
    ActionDrawerButton * button = (ActionDrawerButton*)sender;
    
    if([self.delegate respondsToSelector:@selector(actionDrawerView:didTapActionWithType:)]) {
        [self.delegate performSelector:@selector(actionDrawerView:didTapActionWithType:)
                            withObject:self withObject:@(button.drawerButtonType)];
    }
}

@end
