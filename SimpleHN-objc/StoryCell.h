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
#import "MCSwipeTableViewCell.h"
#import "StoryCommentBaseTableViewCell.h"
#import "TTTAttributedLabel.h"

// Different parts of the cell are visible in the list vs detail context
// Eg. Ask HN label displays in detail but not list. Comments button not catching taps
// in detail, because we're already displaying comments/detail
typedef NS_ENUM(NSInteger, StoryCellContextType) {
    StoryCellContextTypeList,
    StoryCellContextTypeDetail,
};

@protocol StoryCellDelegate;
@interface StoryCell : StoryCommentBaseTableViewCell <ActionDrawerViewDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) Story * story;
@property (nonatomic, assign) __unsafe_unretained id<StoryCellDelegate> storyCellDelegate;

@property (nonatomic, assign) StoryCellContextType contextType;

// Centralised point where action handling code can be invoked
+ (void)handleActionForStory:(Story*)story withType:
    (NSNumber*)type inController:(UIViewController*)controller;

+ (CGFloat)heightForStoryCellWithStory:(Story*)story width:(CGFloat)width;
+ (CGFloat)heightForStoryCellWithStory:(Story*)story width:(CGFloat)width context:(StoryCellContextType)contextType;

@end

@protocol StoryCellDelegate <NSObject>
- (void)storyCellDidDisplayActionDrawer:(StoryCell*)cell;
- (void)storyCellDidTapCommentsArea:(StoryCell*)cell;
- (void)storyCell:(StoryCell*)cell didTapActionWithType:(NSNumber*)type;
- (void)storyCell:(StoryCell*)cell didTapLink:(NSURL*)link; // Show HN/ Ask HN

@end