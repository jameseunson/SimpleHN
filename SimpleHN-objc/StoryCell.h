//
//  StoryCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"
#import "StoryActionDrawerView.h"

@protocol StoryCellDelegate;
@interface StoryCell : UITableViewCell <StoryActionDrawerViewDelegate>

@property (nonatomic, strong) Story * story;
@property (nonatomic, assign) __unsafe_unretained id<StoryCellDelegate> delegate;

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

@end

@protocol StoryCellDelegate <NSObject>
- (void)storyCellDidDisplayActionDrawer:(StoryCell*)cell;
- (void)storyCell:(StoryCell*)cell didTapActionWithType:(NSNumber*)type;
@end