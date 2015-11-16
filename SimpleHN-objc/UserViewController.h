//
//  UserViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "StoryCell.h"
#import "CommentCell.h"
#import "UserHeaderView.h"

@interface UserViewController : UITableViewController <StoryCellDelegate,
    CommentCellDelegate, UserHeaderViewDelegate>

@property (nonatomic, strong) User * user;

@end
