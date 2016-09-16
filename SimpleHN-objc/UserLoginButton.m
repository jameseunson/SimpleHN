//
//  UserLoginButton.m
//  SimpleHN-objc
//
//  Created by James Eunson on 16/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "UserLoginButton.h"

@interface UserLoginButton ()

- (void)didTouchDown:(id)sender;
- (void)didTouchUp:(id)sender;

@end

@implementation UserLoginButton

- (instancetype)init {
    self = [super init];
    if(self) {
        
        self.layer.cornerRadius = 4.0f;
        
        [self setBackgroundColor:RGBCOLOR(238, 238, 238)];
        
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        [self setTitle:@"Login" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        
        [self addTarget:self action:@selector(didTouchDown:)
            forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUp:)
            forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel)];
    }
    return self;
}

- (void)didTouchDown:(id)sender {
    self.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f
                                            blue:221.0f/255.0f alpha:1.0f];
}
- (void)didTouchUp:(id)sender {
    self.backgroundColor = RGBCOLOR(238, 238, 238);
}

@end
