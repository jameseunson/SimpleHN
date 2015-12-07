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

@interface UserViewController ()

@property (nonatomic, strong) UserHeaderView * headerView;

- (void)applyFiltering;
- (void)loadVisibleItems;

@end

@implementation UserViewController

- (void)dealloc {
    [self.loadingProgress removeObserver:self
                          forKeyPath:@"fractionCompleted"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    
    [self.loadingProgress removeObserver:self
                              forKeyPath:@"fractionCompleted"];
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:20];
    [self.loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                              options:NSKeyValueObservingOptionNew context:NULL];
    
    masterProgress.completedUnitCount = 0;
    masterProgress.totalUnitCount = 20;
    [masterProgress addChild:self.loadingProgress withPendingUnitCount:20];
}

- (void)loadView {
    [super loadView];
    
    self.headerView = [[UserHeaderView alloc] init];
    _headerView.delegate = self;
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.author) {
        [User createUserFromItemIdentifier:self.author completion:^(User *user) {
            self.user = user;
        }];
    }
}

#pragma mark - UITableViewDataSource Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.row == self.currentVisibleItemMax && self.user
       && [self.user.submitted count] > 0) {
        
        [self loadMoreItems];
        
    } else {
        
//        id item = [self itemForIndexPath:indexPath];
//        if([item isKindOfClass:[Story class]]) {
//            [self performSegueWithIdentifier:@"showDetail" sender:nil];
//            
//        } else {
//            
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            if(self.expandedCellIndexPath) {
//                CommentCell * expandedCell = [self.tableView cellForRowAtIndexPath:
//                                              self.expandedCellIndexPath];
//                expandedCell.expanded = NO;
//            }
//            
//            // User has tapped an expanded cell, toggle only
//            if([indexPath isEqual:self.expandedCellIndexPath]) {
//                self.expandedCellIndexPath = nil;
//                
//            } else { // Otherwise, set new expanded cell
//                self.expandedCellIndexPath = indexPath;
//                
//                CommentCell * expandedCell = [self.tableView cellForRowAtIndexPath:
//                                              self.expandedCellIndexPath];
//                expandedCell.expanded = YES;
//            }
//            
//            [self.tableView beginUpdates];
//            [self.tableView endUpdates];
//        }
    }
}

#pragma mark - Private Methods
- (void)loadMoreItems {
    NSLog(@"UserViewController, loadMoreItems");
    [super loadMoreItems];
    
//    self.loadingProgress.completedUnitCount = 0;
//    self.loadingProgress.totalUnitCount = 20;
    
    self.currentVisibleItemMax += 20;
    [self loadContent:nil];
}

#pragma mark - Property Override Methods
- (void)setUser:(User *)user {
    _user = user;
    
    self.title = self.user.name;
    self.headerView.user = user;
    
    // Content size can only be determined when we have a user object
    // tableHeaderView frame can't be changed once assigned, so we have to
    // size and set here
    CGSize headerContentSize = _headerView.intrinsicContentSize;
    _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                   MAX( headerContentSize.height, 132.0f ) );
    [self.baseTableView setTableHeaderView:_headerView];
    
    if([self.user.submitted count] > self.currentVisibleItemMax) {
        self.shouldDisplayLoadMoreCell = YES;
    } else {
        self.shouldDisplayLoadMoreCell = NO;
    }
    
    [self loadContent:nil];
}

- (void)loadContent:(id)sender {
    [super loadContent:nil];
    
    if([[self.itemsLookup allKeys] count] > 0) {
        
        [self.itemsLookup removeAllObjects];
        [self.itemsLoadStatus removeAllObjects];
        [self.visibleItems removeAllObjects];
        
        [self.baseTableView reloadData];
    }
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    
    [self.loadingProgress removeObserver:self
                              forKeyPath:@"fractionCompleted"];
    
    NSInteger itemsToLoadCount = MIN([self.user.submitted count], 20);
    
    self.loadingProgress = [NSProgress progressWithTotalUnitCount:itemsToLoadCount];
    [self.loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                              options:NSKeyValueObservingOptionNew context:NULL];
    
    masterProgress.completedUnitCount = 0;
    masterProgress.totalUnitCount = itemsToLoadCount;
    [masterProgress addChild:self.loadingProgress withPendingUnitCount:itemsToLoadCount];
    
    int i = 0;
    for(NSNumber * item in self.user.submitted) {
        
        if([self.itemsLoadStatus[item] isEqual:@(StoryLoadStatusLoading)] ||
           [self.itemsLoadStatus[item] isEqual:@(StoryLoadStatusLoaded)]) {
            i++; continue;
            
        } else {
            
            self.itemsLoadStatus[item] = @(StoryLoadStatusNotLoaded);
            if(i < self.currentVisibleItemMax) {
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
                            self.itemsLookup[item] = story;
                            self.itemsLoadStatus[item] = @(StoryLoadStatusLoaded);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(self.loadingProgress.completedUnitCount < self.loadingProgress.totalUnitCount) {
                                    self.loadingProgress.completedUnitCount++;
                                }
                                
//                                NSLog(@"commentCreated: self.loadingProgress.completedUnitCount %lld of %lld",
//                                      self.loadingProgress.completedUnitCount, self.loadingProgress.totalUnitCount);
                                
                                [self applyFiltering];
                            });
                        }];
                        
                    } else if([typeString isEqualToString:@"comment"]) {
                        [Comment createCommentFromSnapshot:snapshot completion:^(Comment *comment) {
                            self.itemsLookup[item] = comment;
                            self.itemsLoadStatus[item] = @(StoryLoadStatusLoaded);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if(self.loadingProgress.completedUnitCount < self.loadingProgress.totalUnitCount) {
                                    self.loadingProgress.completedUnitCount++;
                                }
                                
                                NSLog(@"commentCreated: self.loadingProgress.completedUnitCount %lld of %lld",
                                      self.loadingProgress.completedUnitCount, self.loadingProgress.totalUnitCount);
                                
                                [self applyFiltering];
                            });
                        }];
                    }
                    
                    [itemRef removeAllObservers];
                }];
                
                i++;
            }
        }
    }
}

- (void)applyFiltering {
    
    [self.visibleItems removeAllObjects];
    
    UserHeaderViewVisibleData visibleData = self.headerView.visibleData;
    if(visibleData == UserHeaderViewVisibleDataAll) {
        
        NSArray * loadedItems = [self.user.submitted subarrayWithRange:
                                 NSMakeRange(0, MIN(self.currentVisibleItemMax, [_user.submitted count]))];
        [self.visibleItems addObjectsFromArray:loadedItems];
        
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
            if([self.itemsLoadStatus[identifier] isEqual:@(StoryLoadStatusLoaded)] &&
               [[self.itemsLookup allKeys] containsObject:identifier] &&
               [NSStringFromClass([self.itemsLookup[identifier] class])
                isEqualToString:filterClassName]) {
                   return YES;
               }
            return NO;
        }]];
        [self.visibleItems addObjectsFromArray:filteredCommentItems];
    }
    [self.baseTableView reloadData];
}

#pragma mark - UserHeaderViewDelegate Methods
- (void)userHeaderView:(UserHeaderView*)view didChangeVisibleData:(NSNumber*)data {
    NSLog(@"UserViewController, userHeaderView, didChangeVisibleData");
    [self applyFiltering];
}

- (void)userHeaderView:(UserHeaderView *)view didTapLink:(NSURL *)link {
    NSLog(@"UserViewController, userHeaderView, didTapLink");
    
    SFSafariViewController * controller = [[SFSafariViewController alloc]
                                           initWithURL:link];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - KVO Callback Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    NSNumber * fractionCompleted = change[NSKeyValueChangeNewKey];
    if([fractionCompleted floatValue] == 1.0f) {
        if(!self.loadingView.hidden) {
            self.loadingView.hidden = YES;
        }
        
        [self.baseRefreshControl endRefreshing];
    }
}

@end
