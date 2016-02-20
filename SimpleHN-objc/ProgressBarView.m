//
//  ProgressBarView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 19/02/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "ProgressBarView.h"

static ProgressBarView * _sharedProgressBarView = nil;

@implementation ProgressBarView

+ (ProgressBarView*)sharedProgressBarView {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedProgressBarView = [[ProgressBarView alloc] init];
    });
    return _sharedProgressBarView;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        
        self.frame = CGRectMake(0, self.superview.frame.size.height - kProgressBarHeight, 0, kProgressBarHeight);
        
        self.tag = kProgressBarTag;
    }
    return self;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    
    if(!self.superview) {
//        NSLog(@"ProgressBarView: Not attached to a superview");
        return;
    }
    
    [self.superview bringSubviewToFront:self];
    
    NSLog(@"self.superview.frame = %@", NSStringFromCGRect(self.superview.frame));
    NSLog(@"self.frame = %@", NSStringFromCGRect(self.frame));
    
    [UIView animateWithDuration:0.1 animations:^{
        
        CGFloat verticalPosition = 0;
        
        if([self.superview isKindOfClass:[UITableView class]] && ((UITableView*)self.superview).tableHeaderView != nil) {
            verticalPosition += ((UITableView*)self.superview).tableHeaderView.frame.size.height;
        }
        if(_verticalOffset > 0) {
            verticalPosition += _verticalOffset;
        }
        self.frame = CGRectMake(0, verticalPosition,
                                progress * self.superview.frame.size.width, kProgressBarHeight);
        
    } completion:^(BOOL finished) {
        if(finished && progress == 1.0f) {
            self.frame = CGRectMake(0, 0, 0, kProgressBarHeight);
        }
    }];
}

@end
