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
@property (nonatomic, strong) ActionDrawerButton * actionDrawerContextButton;

@property (nonatomic, strong) NSArray < ActionDrawerButton * > * buttons;
@property (nonatomic, strong) NSDictionary < NSNumber *, ActionDrawerButton * > * buttonsLookup;

@property (nonatomic, strong) CALayer * actionDrawerBorderLayer;
@property (nonatomic, strong) CALayer * actionDrawerBottomBorderLayer;

- (void)didTapActionButton:(id)sender;
- (ActionDrawerButton*)createButtonWithType:(ActionDrawerViewButtonType)type;

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

@end

@implementation ActionDrawerView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        
        _contextType = ActionDrawerViewContextTypeList;
        
        self.actionDrawerContainerView = [[UIStackView alloc] init];
        _actionDrawerContainerView.axis = UILayoutConstraintAxisHorizontal;
        _actionDrawerContainerView.alignment = UIStackViewAlignmentCenter;
        _actionDrawerContainerView.distribution = UIStackViewDistributionFillEqually;
        _actionDrawerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSMutableDictionary * buttonsLookupMutable = [@{} mutableCopy];
        
        self.actionDrawerUserButton = [self createButtonWithType:ActionDrawerViewButtonTypeUser];
        buttonsLookupMutable[@(ActionDrawerViewButtonTypeUser)] = _actionDrawerUserButton;
        
        self.actionDrawerFlagButton = [self createButtonWithType:ActionDrawerViewButtonTypeFlag];
        buttonsLookupMutable[@(ActionDrawerViewButtonTypeFlag)] = _actionDrawerFlagButton;
        
        self.actionDrawerLinkButton = [self createButtonWithType:ActionDrawerViewButtonTypeLink];
        buttonsLookupMutable[@(ActionDrawerViewButtonTypeLink)] = _actionDrawerLinkButton;
        
        self.actionDrawerMoreButton = [self createButtonWithType:ActionDrawerViewButtonTypeMore];
        buttonsLookupMutable[@(ActionDrawerViewButtonTypeMore)] = _actionDrawerMoreButton;
        
        self.actionDrawerContextButton = [self createButtonWithType:ActionDrawerViewButtonTypeContext];
        buttonsLookupMutable[@(ActionDrawerViewButtonTypeContext)] = _actionDrawerContextButton;
        
        [self addSubview:_actionDrawerContainerView];
        
        self.buttonsLookup = [buttonsLookupMutable copy];
        
        self.activeButtonTypes = @[ @(ActionDrawerViewButtonTypeUser), @(ActionDrawerViewButtonTypeFlag),
                                    @(ActionDrawerViewButtonTypeLink), @(ActionDrawerViewButtonTypeMore)];
        
        self.actionDrawerBorderLayer = [CALayer layer];
        _actionDrawerBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_actionDrawerBorderLayer atIndex:100];
        
        self.actionDrawerBottomBorderLayer = [CALayer layer];
        _actionDrawerBottomBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        _actionDrawerBottomBorderLayer.hidden = YES;
        [self.layer insertSublayer:_actionDrawerBottomBorderLayer atIndex:101];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_actionDrawerContainerView);
        
        [self addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                              @"V:|-10-[_actionDrawerContainerView];H:|-0-[_actionDrawerContainerView]-0-|"
                                                                        options:0 metrics:nil views:bindings]];
        
        [self updateNightMode];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionNightFallingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionDawnComingNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _actionDrawerBorderLayer.frame = CGRectMake(0, 0, self.frame.size.width, (1.0f / [[UIScreen mainScreen] scale]));
    _actionDrawerBottomBorderLayer.frame = CGRectMake(0, self.frame.size.height - 1.0f, self.frame.size.width, (1.0f / [[UIScreen mainScreen] scale]));
}

#pragma mark - Property Override Methods
- (void)setActiveButtonTypes:(NSArray<NSNumber *> *)activeButtonTypes {
    _activeButtonTypes = activeButtonTypes;
    
    NSArray * arrangedViews = [_actionDrawerContainerView.arrangedSubviews copy];
    for(ActionDrawerButton * button in arrangedViews) {
        [_actionDrawerContainerView removeArrangedSubview:button];
    }
    
    for(NSNumber * typeObj in activeButtonTypes) {
        ActionDrawerButton * button = _buttonsLookup[typeObj];
        [_actionDrawerContainerView addArrangedSubview:button];
    }

    [self setNeedsLayout];
}

- (void)setContextType:(ActionDrawerViewContextType)contextType {
    _contextType = contextType;
    
    if(contextType == ActionDrawerViewContextTypeList) {
        _actionDrawerBottomBorderLayer.hidden = YES;
    } else {
        _actionDrawerBottomBorderLayer.hidden = NO;
    }
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

- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}

- (void)updateNightMode {
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        _actionDrawerBorderLayer.backgroundColor = [kNightDefaultBorderColor CGColor];
        _actionDrawerBottomBorderLayer.backgroundColor = [kNightDefaultBorderColor CGColor];
    } else {
        _actionDrawerBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        _actionDrawerBottomBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
    }
}

@end
