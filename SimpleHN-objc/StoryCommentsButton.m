//
//  StoryCommentsButton.m
//  SimpleHN-objc
//
//  Created by James Eunson on 31/10/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCommentsButton.h"

@interface StoryCommentsButton ()

@property (nonatomic, strong) UILabel * commentsCountLabel;
@property (nonatomic, strong) UIView * tapFeedbackBackgroundView;

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

@end

@implementation StoryCommentsButton

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        
        _tapFeedbackViewVisible = NO;
        
        self.tapFeedbackBackgroundView = [[UIView alloc] init];
        _tapFeedbackBackgroundView.backgroundColor = UIColorFromRGB(0xEEEEEE);
        _tapFeedbackBackgroundView.layer.cornerRadius = 4.0f;
        _tapFeedbackBackgroundView.hidden = YES;
        [self addSubview:_tapFeedbackBackgroundView];
        
        self.commentsCountLabel = [LabelHelper labelWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]];
        _commentsCountLabel.textColor = [UIColor lightGrayColor];
        _commentsCountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_commentsCountLabel];
        
//        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
//        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 4.0f;
        
        self.userInteractionEnabled = NO;
        
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
    
    self.commentsCountLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.tapFeedbackBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Property Override Methods
- (void)setStory:(Story *)story {
    _story = story;
    
    _commentsCountLabel.text = [NSString stringWithFormat:@"%lu",
                                [story.totalCommentCount integerValue]];
    
    [self setTitle:[NSString stringWithFormat:@"%lu",
                    [story.totalCommentCount integerValue]] forState:UIControlStateNormal];
    [self sizeToFit];
    [self setTitle:nil forState:UIControlStateNormal];
}

- (void)setTapFeedbackViewVisible:(BOOL)tapFeedbackViewVisible {
    _tapFeedbackViewVisible = tapFeedbackViewVisible;

    if(tapFeedbackViewVisible) {
        _tapFeedbackBackgroundView.hidden = NO;
    } else {
        _tapFeedbackBackgroundView.hidden = YES;
    }
}

- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}

- (void)updateNightMode {
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        _tapFeedbackBackgroundView.backgroundColor = UIColorFromRGB(0x222222);
    } else {
        _tapFeedbackBackgroundView.backgroundColor = UIColorFromRGB(0xEEEEEE);
    }
}

@end
