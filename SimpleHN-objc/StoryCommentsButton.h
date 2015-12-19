//
//  StoryCommentsButton.h
//  SimpleHN-objc
//
//  Created by James Eunson on 31/10/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

#define kCommentsButtonWidth 30.0f
#define kCommentsButtonHeight 26.0f

@interface StoryCommentsButton : UIButton
@property (nonatomic, strong) Story * story;

@property (nonatomic, assign) BOOL tapFeedbackViewVisible;

@end
