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
#import "StoryCommentsNoCommentsCell.h"
#import "ActionDrawerButton.h"

@import SafariServices;

#define kNoItemsReuseIdentifier @"noItemsReuseIdentifier"

@interface UserViewController ()

@property (nonatomic, strong) UserHeaderView * headerView;
@property (nonatomic, strong) NSMutableArray < id > * flatObjectsList;

- (void)applyFiltering;
- (void)loadVisibleItems;
- (void)expandCollapseItemForRow:(NSIndexPath *)indexPath;

@end

@implementation UserViewController

- (void)dealloc {
    [self.loadingProgress removeObserver:self
                          forKeyPath:@"fractionCompleted"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.flatObjectsList = [[NSMutableArray alloc] init];
    
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
    
    [self.tableView registerClass:[StoryCommentsNoCommentsCell class]
           forCellReuseIdentifier:kNoItemsReuseIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.author) {
        [User createUserFromItemIdentifier:self.author completion:^(User *user) {
            self.user = user;
        }];
    }
    
//    [User createUserFromItemIdentifier:@"markmassie" completion:^(User *user) {
//        self.user = user;
//    }];
    
//    [User createUserFromItemIdentifier:@"ColinWright" completion:^(User *user) {
//        self.user = user;
//    }];
    
//    [User createUserFromItemIdentifier:@"perlpimp" completion:^(User *user) {
//        self.user = user;
//    }];
    
//    [User createUserFromItemIdentifier:@"graue" completion:^(User *user) {
//        self.user = user;
//    }];
}

#pragma mark - UITableViewDataSource Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == self.currentVisibleItemMax && self.user
       && [self.user.submitted count] > 0) {
        
        [self loadMoreItems];
        
    } else {
        [self expandCollapseItemForRow:indexPath];
    }
}

#pragma mark - Private Methods
- (void)expandCollapseItemForRow:(NSIndexPath *)indexPath {
    
    NSNumber * identifier = self.visibleItems[indexPath.row];
    id item = self.itemsLookup[identifier];
    
    NSArray * expandedItemArray = [self.flatObjectsList filteredArrayUsingPredicate:
        [NSPredicate predicateWithFormat:@"sizeStatus == %lu", CommentSizeStatusExpanded]];
    
    if([expandedItemArray count] > 0) {
        id expandedItem = [expandedItemArray firstObject];
        if([expandedItem isKindOfClass:[Comment class]]) {
            Comment * expandedComment = (Comment *)expandedItem;
            expandedComment.sizeStatus = CommentSizeStatusNormal;
            
        } else {
            Story * expandedStory = (Story *)expandedItem;
            expandedStory.sizeStatus = StorySizeStatusNormal;
        }
        
        // Job done, don't expand again        
        if(item == expandedItem) {
            [self.tableView beginUpdates];
            [self.tableView endUpdates];

            return;
        }
    }
    
    if([item isKindOfClass:[Comment class]]) {
        Comment * comment = (Comment *)item;
        comment.sizeStatus = CommentSizeStatusExpanded;
        
    } else {
        Story * story = (Story *)item;
        story.sizeStatus = StorySizeStatusExpanded;
    }

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

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
    [self.tableView setTableHeaderView:_headerView];
    
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
        [self.flatObjectsList removeAllObjects];
        
        [self.tableView reloadData];
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
                            [self.flatObjectsList addObject:story];
                            
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
                            [self.flatObjectsList addObject:comment];
                            
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
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.initialLoadDone) {
        
        if(indexPath.row == [self.visibleItems count] && [self.visibleItems count] > 0
           && self.shouldDisplayLoadMoreCell) {
            
            StoryLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                       kStoryLoadMoreCellReuseIdentifier forIndexPath:indexPath];
            return cell;
            
        } else {
            
            id item = [self itemForIndexPath:indexPath];
            if([item isKindOfClass:[Story class]]) {
                
                StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                   kStoryCellReuseIdentifier forIndexPath:indexPath];
                cell.story = item;
                
                cell.storyCellDelegate = self;
                cell.votingDelegate = self;
                
                return cell;
                
            } else {
                
                CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier
                                                                     forIndexPath:indexPath];
                cell.comment = item;
                cell.commentCellDelegate = self;
                
                cell.actionDrawerView.activeButtonTypes = @[ @(ActionDrawerViewButtonTypeFlag), @(ActionDrawerViewButtonTypeLink),
                                                             @(ActionDrawerViewButtonTypeContext), @(ActionDrawerViewButtonTypeMore)];
                
                return cell;
            }
        }
        
    } else {
        
        StoryCommentsContentLoadingCell * cell = [tableView dequeueReusableCellWithIdentifier:
                                                  kStoryCommentsContentLoadingCellReuseIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - UserHeaderViewDelegate Methods
- (void)userHeaderView:(UserHeaderView*)view didChangeVisibleData:(NSNumber*)data {
    NSLog(@"UserViewController, userHeaderView, didChangeVisibleData");
    [self applyFiltering];
}

- (void)userHeaderView:(UserHeaderView *)view didTapLink:(NSURL *)link {
    NSLog(@"UserViewController, userHeaderView, didTapLink");
    
    if([link isHNInternalLink]) {
        
        if([link isHNInternalItemLink]) {
            NSNumber * identifier = [link identifierForHNInternalItemLink];
            if(identifier) {
                [self performSegueWithIdentifier:@"showDetail" sender:identifier]; return;
            }
            
        } else if([link isHNInternalUserLink]) {
            NSString * username = [link usernameForHNInternalUserLink];
            if(username) {
                [self performSegueWithIdentifier:@"showUser" sender:username]; return;
            }
        }
    } // Catches two else cases implicitly
    
    NSLog(@"%@", link);
    [self performSegueWithIdentifier:@"showWeb" sender:nil];
}

#pragma mark - KVO Callback Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    NSNumber * fractionCompleted = change[NSKeyValueChangeNewKey];
    
    if([fractionCompleted floatValue] > 0.0f && !self.initialLoadDone) {
        self.initialLoadDone = YES;
    }
    
    if([fractionCompleted floatValue] == 1.0f) {
        
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [self.refreshDateFormatter stringFromDate:[NSDate date]]];
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:
                                                   @{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
        } else {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:
                                                   @{ NSForegroundColorAttributeName: [UIColor grayColor] }];
        }
        [self.refreshControl endRefreshing];
    }
}

@end
