//
//  UserViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "UserViewController.h"
#import "StoryLoadMoreCell.h"
#import "SuProgress.h"
#import "ContentLoadingView.h"

@import SafariServices;

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kStoryLoadMoreCellReuseIdentifier @"storyLoadMoreCellReuseIdentifier"
#define kCommentCellReuseIdentifier @"kCommentCellReuseIdentifier"

@interface UserViewController ()

@property (nonatomic, strong) UserHeaderView * headerView;

@property (nonatomic, strong) NSMutableDictionary < NSNumber *, NSNumber * > * itemsLoadStatus;
@property (nonatomic, strong) NSMutableDictionary < NSNumber *, id > * itemsLookup;

@property (nonatomic, strong) NSMutableArray < NSNumber * > * visibleItems;

@property (nonatomic, assign) NSInteger currentVisibleStoryMax;
@property (nonatomic, strong) NSIndexPath * expandedCellIndexPath;

@property (nonatomic, strong) NSProgress * loadingProgress;

@property (nonatomic, strong) ContentLoadingView * loadingView;

- (void)loadMoreItems:(id)sender;
- (void)applyFiltering;

@end

@implementation UserViewController

- (void)dealloc {
    [_loadingProgress removeObserver:self
                          forKeyPath:@"fractionCompleted"];
}

- (void)awakeFromNib {
    
    _currentVisibleStoryMax = 20;
    
    self.visibleItems = [[NSMutableArray alloc] init];
    
    self.itemsLoadStatus = [[NSMutableDictionary alloc] init];
    self.itemsLookup = [[NSMutableDictionary alloc] init];
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:
                            _currentVisibleStoryMax];
    [_loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                          options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)loadView {
    [super loadView];
    
    self.headerView = [[UserHeaderView alloc] init];
    _headerView.delegate = self;
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.tableView = [[UITableView alloc] initWithFrame:
                      CGRectZero style:UITableViewStylePlain];
    
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
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_tableView];
    
    self.loadingView = [[ContentLoadingView alloc] init];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_loadingView];

    [self SuProgressForProgress:self.loadingProgress];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_loadingView, _tableView);
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_loadingView]|;V:|[_loadingView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"H:|[_tableView]|;V:|[_tableView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 132.0f);
    [self.tableView setTableHeaderView:_headerView];
    
    self.headerView.user = self.user;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        Story * story = [self itemForIndexPath:
                         [self.tableView indexPathForSelectedRow]];
        
        StoryDetailViewController *controller = (StoryDetailViewController *)
            [[segue destinationViewController] topViewController];
        [controller setDetailItem:story];
        
        controller.navigationItem.leftBarButtonItem =
        self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(!self.user) {
        return 0;
    }
    
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
    if(indexPath.row == [_visibleItems count] && self.user
       && [_visibleItems count] > 0) {
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.row == _currentVisibleStoryMax && self.user
       && [self.user.submitted count] > 0) {
        
        [self loadMoreItems:nil];
        
    } else {
        
        id item = [self itemForIndexPath:indexPath];
        if([item isKindOfClass:[Story class]]) {
            [self performSegueWithIdentifier:@"showDetail" sender:nil];
            
        } else {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if(_expandedCellIndexPath) {
                CommentCell * expandedCell = [self.tableView cellForRowAtIndexPath:
                                              _expandedCellIndexPath];
                expandedCell.expanded = NO;
            }
            
            // User has tapped an expanded cell, toggle only
            if([indexPath isEqual:_expandedCellIndexPath]) {
                _expandedCellIndexPath = nil;
                
            } else { // Otherwise, set new expanded cell
                self.expandedCellIndexPath = indexPath;
                
                CommentCell * expandedCell = [self.tableView cellForRowAtIndexPath:
                                              _expandedCellIndexPath];
                expandedCell.expanded = YES;
            }
            
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - Private Methods
- (id)itemForIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *identifier = _visibleItems[indexPath.row];
    if([[_itemsLookup allKeys] containsObject:identifier]) {
        return _itemsLookup[identifier];
    } else {
        return nil;
    }
}

- (void)loadMoreItems:(id)sender {
    
}

#pragma mark - Property Override Methods
- (void)setUser:(User *)user {
    _user = user;
    
    self.title = self.user.name;
    self.headerView.user = user;
    
    // Initially unfiltered
    [_visibleItems addObjectsFromArray:self.user.submitted];
    
    // Ensure that if the user has < 20 submissions,
    // the page isn't endlessly stuck loading
    self.loadingProgress.completedUnitCount = 0;
    self.loadingProgress.totalUnitCount = MIN(_currentVisibleStoryMax,
                                              [_user.submitted count]);
    
    int i = 0;
    for(NSNumber * item in self.user.submitted) {
        
        if([_itemsLoadStatus[item] isEqual:@(StoryLoadStatusLoading)] ||
           [_itemsLoadStatus[item] isEqual:@(StoryLoadStatusLoaded)]) {
            i++; continue;
            
        } else {
            
            _itemsLoadStatus[item] = @(StoryLoadStatusNotLoaded);
            if(i < _currentVisibleStoryMax) {
                NSString * itemUrl = [NSString stringWithFormat:
                                      @"https://hacker-news.firebaseio.com/v0/item/%@", item];
                
                __block Firebase * itemRef = [[Firebase alloc] initWithUrl:itemUrl];
                [itemRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    NSDictionary * value = snapshot.value;
                    
                    if(![snapshot.value isKindOfClass:[NSDictionary class]] ||
                       ![[value allKeys] containsObject:@"type"]) {
                        return;
                    }
                    
                    NSString * typeString = value[@"type"];
                    if([typeString isEqualToString:@"story"]) {
                        [Story createStoryFromSnapshot:snapshot completion:^(Story *story) {
                            _itemsLookup[item] = story;
                            _itemsLoadStatus[item] = @(StoryLoadStatusLoaded);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.loadingProgress.completedUnitCount++;
                                [self applyFiltering];
                            });
                        }];
                        
                    } else if([typeString isEqualToString:@"comment"]) {
                        [Comment createCommentFromSnapshot:snapshot completion:^(Comment *comment) {
                            _itemsLookup[item] = comment;
                            _itemsLoadStatus[item] = @(StoryLoadStatusLoaded);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.loadingProgress.completedUnitCount++;
                                [self applyFiltering];
                            });
                        }];
                    }
                    
                    [itemRef removeAllObservers];
                }];
                
                NSLog(@"%@", itemUrl);
                i++;
            }
        }
    }
}

- (void)applyFiltering {
    
    [_visibleItems removeAllObjects];
    
    UserHeaderViewVisibleData visibleData = self.headerView.visibleData;
    if(visibleData == UserHeaderViewVisibleDataAll) {
        [self.visibleItems addObjectsFromArray:self.user.submitted];
        
    } else if(visibleData == UserHeaderViewVisibleDataComments ||
              visibleData == UserHeaderViewVisibleDataSubmissions) {
        
        NSString * filterClassName = nil;
        if(visibleData == UserHeaderViewVisibleDataSubmissions) {
            filterClassName = @"Story";
            
        } else if(visibleData == UserHeaderViewVisibleDataComments) {
            filterClassName = @"Comment";
        }
        
        NSArray * filteredCommentItems = [self.user.submitted filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            
            NSNumber * identifier = (NSNumber*)evaluatedObject;
            if([_itemsLoadStatus[identifier] isEqual:@(StoryLoadStatusLoaded)] &&
               [[_itemsLookup allKeys] containsObject:identifier] &&
               [NSStringFromClass([_itemsLookup[identifier] class])
                isEqualToString:filterClassName]) {
                   return YES;
               }
            return NO;
        }]];
        [self.visibleItems addObjectsFromArray:filteredCommentItems];
    }
    [self.tableView reloadData];
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

#pragma mark - UserHeaderViewDelegate Methods
- (void)userHeaderView:(UserHeaderView*)view didChangeVisibleData:(NSNumber*)data {
    NSLog(@"UserViewController, userHeaderView, didChangeVisibleData");
    [self applyFiltering];
}

#pragma mark - KVO Callback Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    NSLog(@"UserViewController, %@", change);
    
    NSNumber * fractionCompleted = change[NSKeyValueChangeNewKey];
    if([fractionCompleted floatValue] == 1.0f) {
        if(!_loadingView.hidden) {
            _loadingView.hidden = YES;
        }
    }
}

@end
