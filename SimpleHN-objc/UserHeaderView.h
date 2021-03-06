//
//  UserHeaderView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TTTAttributedLabel.h"

typedef NS_ENUM(NSInteger, UserHeaderViewVisibleData) {
    UserHeaderViewVisibleDataAll,
    UserHeaderViewVisibleDataSubmissions,
    UserHeaderViewVisibleDataComments
};

@protocol UserHeaderViewDelegate;
@interface UserHeaderView : UIView <UITextViewDelegate, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) User * user;
@property (nonatomic, assign) __unsafe_unretained id<UserHeaderViewDelegate> delegate;

@property (nonatomic, assign) UserHeaderViewVisibleData visibleData;

+ (CGFloat)heightWithUser:(User*)user forWidth:(CGFloat)width;

@end

@protocol UserHeaderViewDelegate <NSObject>
- (void)userHeaderView:(UserHeaderView*)view didChangeVisibleData:(NSNumber*)data;
- (void)userHeaderView:(UserHeaderView*)view didTapLink:(NSURL*)link;
@end