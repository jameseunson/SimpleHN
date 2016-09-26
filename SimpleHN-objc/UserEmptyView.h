//
//  UserEmptyView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 16/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserEmptyViewDelegate;
@interface UserEmptyView : UIView

@property (nonatomic, assign) __unsafe_unretained id<UserEmptyViewDelegate> delegate;

- (void)updateNightMode;

@end

@protocol UserEmptyViewDelegate <NSObject>
- (void)userEmptyView:(UserEmptyView*)view didTapLoginButton:(UIButton*)button;
@end
