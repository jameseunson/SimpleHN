//
//  StoryCommentsButton.m
//  SimpleHN-objc
//
//  Created by James Eunson on 31/10/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCommentsButton.h"

@implementation StoryCommentsButton

- (instancetype)init {
    self = [super init];
    if(self) {
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 4.0f;
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setStory:(Story *)story {
    _story = story;
    
    [self setTitle:[NSString stringWithFormat:@"%lu",
                    [story.totalCommentCount integerValue]] forState:UIControlStateNormal];
    [self sizeToFit];
}

@end
