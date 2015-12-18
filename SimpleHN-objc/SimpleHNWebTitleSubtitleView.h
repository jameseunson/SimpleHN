//
//  SimpleHNWebTitleSubtitleView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 18/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimpleHNWebTitleSubtitleViewDelegate;
@interface SimpleHNWebTitleSubtitleView : UIView

@property (nonatomic, assign) __unsafe_unretained id<SimpleHNWebTitleSubtitleViewDelegate> delegate;

@property (nonatomic, strong) NSString * titleString;
@property (nonatomic, strong) NSString * subtitleString;

@end

@protocol SimpleHNWebTitleSubtitleViewDelegate <NSObject>
- (void)simpleHNWebTitleSubtitleViewDidTapView:(SimpleHNWebTitleSubtitleView*)view;
@end