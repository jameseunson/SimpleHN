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
#import "StoriesCommentsBaseViewController.h"

@interface UserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
    StoryCellDelegate, CommentCellDelegate, UserHeaderViewDelegate>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) User * user;

@end
