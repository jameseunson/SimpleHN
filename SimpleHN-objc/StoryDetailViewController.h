//
//  DetailViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Firebase.h"

#import "Comment.h"
#import "CommentCell.h"
#import "Story.h"
#import "StoryCell.h"

@import SafariServices;

typedef NS_ENUM(NSInteger, StoryDetailViewControllerDisplayMode) {
    StoryDetailViewControllerDisplayModeStory = 0,
    StoryDetailViewControllerDisplayModeCommentContext = 1
};

@interface StoryDetailViewController : UITableViewController <CommentCellDelegate, StoryCellDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, strong) Story * detailItem;

// Alternative 'comment context' mode, show comment, immediate parent
// comment, and story context
@property (nonatomic, strong) Comment * detailComment;

@end

