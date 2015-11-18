//
//  StoryActionButton.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ActionDrawerViewButtonType) {
    ActionDrawerViewButtonTypeUser,
    ActionDrawerViewButtonTypeFlag,
    ActionDrawerViewButtonTypeLink,
    ActionDrawerViewButtonTypeMore
};

@interface ActionDrawerButton : UIButton

@property (nonatomic, assign) ActionDrawerViewButtonType drawerButtonType;

+ (ActionDrawerButton*)buttonWithType:(ActionDrawerViewButtonType)type;

@end
