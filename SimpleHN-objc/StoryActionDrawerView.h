//
//  StoryActionDrawerView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StoryActionDrawerViewButtonType) {
    StoryActionDrawerViewButtonTypeUser,
    StoryActionDrawerViewButtonTypeFlag,
    StoryActionDrawerViewButtonTypeLink,
    StoryActionDrawerViewButtonTypeMore
};

@protocol StoryActionDrawerViewDelegate;
@interface StoryActionDrawerView : UIView

@property (nonatomic, strong) NSArray < NSNumber * > * buttonTypes;
@property (nonatomic, assign) __unsafe_unretained
    id<StoryActionDrawerViewDelegate> delegate;

@end

@protocol StoryActionDrawerViewDelegate <NSObject>
- (void)storyActionDrawerView:(StoryActionDrawerView*)view
        didTapActionWithType:(NSNumber*)type;
@end