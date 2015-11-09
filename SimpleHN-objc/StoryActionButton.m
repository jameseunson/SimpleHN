//
//  StoryActionButton.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryActionButton.h"

@interface StoryActionButton ()

- (void)didTouchDown:(id)sender;
- (void)didTouchUp:(id)sender;

@end

@implementation StoryActionButton

- (instancetype)init {
    self = [super init];
    if(self) {
        
        self.alpha = 0.2f;
        
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:
            (UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel)];
        
        [self addTarget:self action:@selector(didTouchDown:)
            forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)didTouchDown:(id)sender {
    self.alpha = 0.6f;
}

- (void)didTouchUp:(id)sender {
    self.alpha = 0.2f;
}

@end
