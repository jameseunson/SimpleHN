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

@end

@implementation ActionDrawerButton

- (instancetype)init {
    self = [super init];
    if(self) {
        
        self.alpha = 0.4f;
        
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:
            (UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel)];
        
        [self addTarget:self action:@selector(didTouchDown:)
            forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)didTouchDown:(id)sender {
    self.alpha = 1.0f;
}

- (void)didTouchUp:(id)sender {
    self.alpha = 0.4f;
}

@end
