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
        
        [self setBackgroundColor:[UIColor clearColor]];
        
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
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.backgroundColor = RGBCOLOR(51, 51, 51);
        
    } else {
        self.backgroundColor = RGBCOLOR(221, 221, 221);
    }
}
- (void)didTouchUp:(id)sender {
    self.backgroundColor = [UIColor clearColor];
}


@end
