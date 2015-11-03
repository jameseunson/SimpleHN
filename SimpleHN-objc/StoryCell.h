//
//  StoryCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface StoryCell : UITableViewCell

@property (nonatomic, strong) Story * story;
//
//@property (nonatomic, strong) IBOutlet UILabel * storyTitleLabel;
//@property (nonatomic, strong) IBOutlet UILabel * storySubtitleLabel;
//
//@property (nonatomic, strong) IBOutlet UIButton * storyCommentsButton;
//@property (nonatomic, strong) IBOutlet UILabel * storyRatingLabel;

@end
