//
//  TopStoriesTitleView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopStoriesTitleViewDelegate;
@interface TopStoriesTitleView : UIView

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;

@property (nonatomic, assign) __unsafe_unretained id<TopStoriesTitleViewDelegate> delegate;

@end

@protocol TopStoriesTitleViewDelegate <NSObject>
- (void)topStoriesTitleViewDidTapTitleView:(TopStoriesTitleView*)view;
@end