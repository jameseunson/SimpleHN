//
//  StoryActionButton.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "ActionDrawerButton.h"

@interface ActionDrawerButton ()

- (void)didTouchDown:(id)sender;
- (void)didTouchUp:(id)sender;

- (void)nightModeEvent:(NSNotification*)notification;

@end

@implementation ActionDrawerButton

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:
            (UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel)];
        
        [self addTarget:self action:@selector(didTouchDown:)
            forControlEvents:UIControlEventTouchDown];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionNightFallingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionDawnComingNotification object:nil];
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            self.tintColor = [UIColor orangeColor];
            self.alpha = 1.0f;
            
        } else {
            self.tintColor = [UIColor blackColor];
            self.alpha = 0.4f;
        }
    }
    return self;
}

+ (ActionDrawerButton*)buttonWithType:(ActionDrawerViewButtonType)type {
    
    ActionDrawerButton * button = [[ActionDrawerButton alloc] init];
    button.drawerButtonType = type;
    return button;
}

// Override to ensure these buttons are actually tappable
// regardless of image height, where they would otherwise
// derive their intrinsic content size
- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0f);
}

- (void)didTouchDown:(id)sender {
    self.alpha = 1.0f;
}

- (void)didTouchUp:(id)sender {
    if(![[AppConfig sharedConfig] nightModeEnabled]) {
        self.alpha = 0.4f;
    }
}

- (void)nightModeEvent:(NSNotification*)notification {
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.tintColor = [UIColor orangeColor];
        self.alpha = 1.0f;
        
    } else {
        self.tintColor = [UIColor blackColor];
        self.alpha = 0.4f;
    }
}

#pragma mark - Property Override Methods
- (void)setDrawerButtonType:(ActionDrawerViewButtonType)drawerButtonType {
    _drawerButtonType = drawerButtonType;
    
    if(drawerButtonType == ActionDrawerViewButtonTypeUser) {
        [self setImage:[[UIImage imageNamed:@"story-action-user-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateNormal];
        
    } else if(drawerButtonType == ActionDrawerViewButtonTypeFlag) {
        [self setImage:[[UIImage imageNamed:@"story-action-flag-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateNormal];
        
    } else if(drawerButtonType == ActionDrawerViewButtonTypeShare) {
        [self setImage:[[UIImage imageNamed:@"story-action-share-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateNormal];
        
    } else if(drawerButtonType == ActionDrawerViewButtonTypeLink) {
        [self setImage:[[UIImage imageNamed:@"story-action-link-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateNormal];
        
    } else if(drawerButtonType == ActionDrawerViewButtonTypeMore) {
        [self setImage:[[UIImage imageNamed:@"story-action-more-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateNormal];
        
    } else if(drawerButtonType == ActionDrawerViewButtonTypeContext) {
        [self setImage:[[UIImage imageNamed:@"story-action-context-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
              forState:UIControlStateNormal];
    }
}

@end
