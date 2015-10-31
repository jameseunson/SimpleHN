//
//  StoryCommentsButton.h
//  SimpleHN-objc
//
//  Created by James Eunson on 31/10/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface StoryCommentsButton : UIButton
@property (nonatomic, strong) Story * story;

@end
