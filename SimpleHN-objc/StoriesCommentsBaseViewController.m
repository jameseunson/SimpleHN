//
//  StoriesCommentsBaseViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsBaseViewController.h"

@import SafariServices;

@implementation StoriesCommentsBaseViewController

- (void)awakeFromNib {
    
    _currentVisibleItemMax = 20;
    
    self.visibleItems = [[NSMutableArray alloc] init];
    
    self.itemsLoadStatus = [[NSMutableDictionary alloc] init];
    self.itemsLookup = [[NSMutableDictionary alloc] init];
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:
                      CGRectZero style:UITableViewStylePlain];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[StoryCell class]
           forCellReuseIdentifier:kStoryCellReuseIdentifier];
    [self.tableView registerClass:[StoryLoadMoreCell class]
           forCellReuseIdentifier:kStoryLoadMoreCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_tableView];
    
    self.loadingView = [[ContentLoadingView alloc] init];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_loadingView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_loadingView, _tableView);
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_loadingView]|;V:|[_loadingView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_tableView]|;V:|[_tableView]|" options:0 metrics:nil views:bindings]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //    NSInteger itemsCount = MIN(_currentVisibleStoryMax, [self.user.submitted count]);
    //    if(itemsCount > 0) {
    //        itemsCount = itemsCount + 1;
    //    }
    //    return itemsCount;
    
    NSInteger itemsCount = [_visibleItems count];
    if(itemsCount > 0) {
        itemsCount = itemsCount + 1;
    }
    return itemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    if(indexPath.row == _currentVisibleStoryMax && self.user
    //       && [self.user.submitted count] > 0) {
    if(indexPath.row == [_visibleItems count] && [_visibleItems count] > 0) {
        
        StoryLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                   kStoryLoadMoreCellReuseIdentifier forIndexPath:indexPath];
        return cell;
        
    } else {
        
        id item = [self itemForIndexPath:indexPath];
        if([item isKindOfClass:[Story class]]) {
            
            StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                               kStoryCellReuseIdentifier forIndexPath:indexPath];
            cell.story = item;
            
            if(_expandedCellIndexPath && [indexPath isEqual:_expandedCellIndexPath]) {
                cell.expanded = YES;
                
            } else {
                cell.expanded = NO;
            }
            
            cell.delegate = self;
            return cell;
            
        } else {
            
            CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier
                                                                 forIndexPath:indexPath];
            cell.comment = item;
            if(_expandedCellIndexPath && [indexPath isEqual:_expandedCellIndexPath]) {
                cell.expanded = YES;
                
            } else {
                cell.expanded = NO;
            }
            
            cell.delegate = self;
            
            return cell;
        }
    }
}

- (id)itemForIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *identifier = _visibleItems[indexPath.row];
    if([[_itemsLookup allKeys] containsObject:identifier]) {
        return _itemsLookup[identifier];
    } else {
        return nil;
    }
}

#pragma mark - StoryCellDelegate Methods
- (void)storyCellDidDisplayActionDrawer:(StoryCell*)cell {
    NSLog(@"storyCellDidDisplayActionDrawer:");
    
    if(_expandedCellIndexPath) {
        StoryCell * expandedCell = [self.tableView cellForRowAtIndexPath:
                                    _expandedCellIndexPath];
        expandedCell.expanded = NO;
    }
    
    self.expandedCellIndexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
- (void)storyCell:(StoryCell*)cell didTapActionWithType:(NSNumber*)type {
    [StoryCell handleActionForStory:cell.story withType:type inController:self];
}

#pragma mark - CommentCellDelegate Methods
- (void)commentCell:(CommentCell*)cell didTapLink:(CommentLink*)link {
    SFSafariViewController * controller = [[SFSafariViewController alloc]
                                           initWithURL:link.url];
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)commentCell:(CommentCell*)cell didTapActionWithType:(NSNumber*)type {
    [CommentCell handleActionForComment:cell.comment withType:type inController:self];
}

@end
