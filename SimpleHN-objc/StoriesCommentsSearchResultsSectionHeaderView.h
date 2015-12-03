//
//  LibraryResultsSectionHeaderView.h
//  SimpleHN
//
//  Created by James Eunson on 29/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#define kSectionHeaderViewHeight 30.0f

@protocol StoriesCommentsSearchResultsSectionHeaderViewDelegate;
@interface StoriesCommentsSearchResultsSectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UIView * sectionBackgroundView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) CALayer * bottomBorderLayer;

@property (nonatomic, strong) UILabel * actionLabel;

@property (nonatomic, assign) NSInteger totalResultsCount;
@property (nonatomic, assign) NSInteger currentResultStart;
@property (nonatomic, assign) NSInteger currentResultEnd;
@property (nonatomic, assign) BOOL loading;

@property (nonatomic, assign) __unsafe_unretained id<StoriesCommentsSearchResultsSectionHeaderViewDelegate> delegate;

@property (nonatomic, strong) UILabel * filterSubtitleLabel;

@end

@protocol StoriesCommentsSearchResultsSectionHeaderViewDelegate <NSObject>
- (void)storiesCommentsSearchResultsSectionHeaderViewDidTapAdjustFilterButton:(StoriesCommentsSearchResultsSectionHeaderView*)view;
@end
