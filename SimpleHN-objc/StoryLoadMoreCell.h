//
//  StoryLoadMoreCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 3/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryLoadMoreCell : UITableViewCell

@property (nonatomic, strong) UILabel * loadMoreLabel;
@property (nonatomic, strong) UILabel * loadMoreSubtitleLabel;

@property (nonatomic, strong) UIActivityIndicatorView * loadingView;

@end
