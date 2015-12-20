//
//  StoryActionDrawerView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kActionDrawerViewHeight 65.0f

// Bottom border only visible in detail context
typedef NS_ENUM(NSInteger, ActionDrawerViewContextType) {
    ActionDrawerViewContextTypeList,
    ActionDrawerViewContextTypeDetail
};

@protocol ActionDrawerViewDelegate;
@interface ActionDrawerView : UIView

@property (nonatomic, assign) ActionDrawerViewContextType contextType;

@property (nonatomic, assign) __unsafe_unretained
    id<ActionDrawerViewDelegate> delegate;

@property (nonatomic, strong) NSArray < NSNumber * > * activeButtonTypes;

@end

@protocol ActionDrawerViewDelegate <NSObject>
- (void)actionDrawerView:(ActionDrawerView*)view
        didTapActionWithType:(NSNumber*)type;
@end