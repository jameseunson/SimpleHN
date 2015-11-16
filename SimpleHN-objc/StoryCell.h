//
//  StoryCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"
#import "ActionDrawerView.h"

@protocol StoryCellDelegate;
@interface StoryCell : UITableViewCell <ActionDrawerViewDelegate>

@property (nonatomic, strong) Story * story;
@property (nonatomic, assign) __unsafe_unretained id<StoryCellDelegate> delegate;

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

// Centralised point where action handling code can be invoked
+ (void)handleActionForStory:(Story*)story withType:
    (NSNumber*)type inController:(UIViewController*)controller;

@end

@protocol StoryCellDelegate <NSObject>
- (void)storyCellDidDisplayActionDrawer:(StoryCell*)cell;
- (void)storyCell:(StoryCell*)cell didTapActionWithType:(NSNumber*)type;
@end