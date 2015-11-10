//
//  UserViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "UserViewController.h"
#import "StoryCell.h"
#import "StoryLoadMoreCell.h"

#import "CommentCell.h"
#import "UserHeaderView.h"

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kStoryLoadMoreCellReuseIdentifier @"storyLoadMoreCellReuseIdentifier"
#define kCommentCellReuseIdentifier @"kCommentCellReuseIdentifier"

@interface UserViewController ()

@property (nonatomic, strong) UserHeaderView * headerView;

@end

@implementation UserViewController

- (void)loadView {
    [super loadView];
    
    self.headerView = [[UserHeaderView alloc] init];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[StoryCell class]
           forCellReuseIdentifier:kStoryCellReuseIdentifier];
    [self.tableView registerClass:[StoryLoadMoreCell class]
           forCellReuseIdentifier:kStoryLoadMoreCellReuseIdentifier];
    [self.tableView registerClass:[CommentCell class]
           forCellReuseIdentifier:kCommentCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 132.0f);
    [self.tableView setTableHeaderView:_headerView];
    
    self.headerView.user = self.user;
}

#pragma mark - Property Override Methods
- (void)setUser:(User *)user {
    _user = user;
    
    self.title = self.user.name;
    self.headerView.user = user;
}

@end
