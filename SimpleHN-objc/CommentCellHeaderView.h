//
//  CommentCellHeaderView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 4/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

#define kCommentCellHeaderViewHeight 25.0f

@interface CommentCellHeaderView : UIView

@property (nonatomic, strong) Comment * comment;
@property (nonatomic, assign) BOOL collapsed;

@end
