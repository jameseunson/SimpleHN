//
//  DetailViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryDetailViewController.h"
#import "Story.h"
#import "UserViewController.h"
#import "SuProgress.h"
#import "ActionDrawerButton.h"
#import "RegexKitLite.h"
#import "StoryCommentsNoCommentsCell.h"

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kCommentCellReuseIdentifier @"commentCellReuseIdentifier"
#define kNoCommentsReuseIdentifier @"noCommentsReuseIdentifier"

@import WebKit;

@interface StoryDetailViewController ()

@property (nonatomic, strong) UISegmentedControl * contentSelectSegmentedControl;
@property (nonatomic, strong) SFSafariViewController * webViewController;

@property (nonatomic, strong) NSProgress * loadingProgress;

@property (nonatomic, strong) UIRefreshControl * baseRefreshControl;
@property (nonatomic, strong) UITableView * baseTableView;

@property (nonatomic, assign) BOOL initialLoadDone;
@property (nonatomic, assign) StoryDetailViewControllerDisplayMode displayMode;

- (void)loadContent;

- (void)reloadContent:(id)sender;
- (void)didSelectContentSegment:(id)sender;

- (void)commentCreated:(NSNotification*)notification;
- (void)commentCollapsedComplete:(NSNotification*)notification;

- (void)expandCollapseCommentForRow:(NSIndexPath *)indexPath;

- (void)configureViewForStory;
- (void)configureViewForComment;

@end

@implementation StoryDetailViewController

#pragma mark - Managing the detail item

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCreated:)
                                                 name:kCommentCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCollapsedComplete:)
                                                 name:kCommentCollapsedComplete object:nil];
    
    _displayMode = StoryDetailViewControllerDisplayModeStory;
    _initialLoadDone = NO;
}

- (void)loadView {
    [super loadView];

    [self.tableView registerClass:[StoryCell class]
           forCellReuseIdentifier:kStoryCellReuseIdentifier];
    
    [self.tableView registerClass:[CommentCell class]
           forCellReuseIdentifier:kCommentCellReuseIdentifier];
    
    [self.tableView registerClass:[StoryCommentsNoCommentsCell class]
           forCellReuseIdentifier:kNoCommentsReuseIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadContent:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.baseRefreshControl = self.refreshControl;
    self.baseTableView = self.tableView;
}

- (void)setDetailItem:(Story*)newDetailItem {
    if (_detailItem != newDetailItem) {
        
        _detailItem = [newDetailItem copy];
        _detailItem.sizeStatus = StorySizeStatusExpanded;
        
        if(_webViewController) {
            [_webViewController.view removeFromSuperview];
            _webViewController = nil;
        }
        
        [self.tableView reloadData];
        [self configureViewForStory];
    }
}

- (void)setDetailComment:(Comment *)newDetailComment {
    if (_detailComment != newDetailComment) {
        
        _detailComment = [newDetailComment copy];
        if(_webViewController) {
            [_webViewController.view removeFromSuperview];
            _webViewController = nil;
        }
        
        _displayMode = StoryDetailViewControllerDisplayModeCommentContext;
        
        [self.tableView reloadData];
        [self configureViewForComment];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController
                                                        .navigationBar.frame.size.height, 0, 0, 0);
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)configureViewForStory {
    
    self.title = _detailItem.title;
    
    if(_displayMode == StoryDetailViewControllerDisplayModeStory) {
        if([_detailItem.flatDisplayComments count] == 0) {
            [self loadContent];
        }
    }
    
    if(!_detailItem.url) {
        self.navigationItem.rightBarButtonItem = nil;
        
    } else {
        UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:_contentSelectSegmentedControl];
        self.navigationItem.rightBarButtonItem = item;
    }
    
    if(self.detailItem.url) {
        BOOL enterReaderModeAutomatically = [[AppConfig sharedConfig] storyAutomaticallyShowReader];
        
        self.webViewController = [[SFSafariViewController alloc] initWithURL:self.detailItem.url
                                                     entersReaderIfAvailable:enterReaderModeAutomatically];
        _webViewController.delegate = self;
        [self addChildViewController:_webViewController];
        
        UIView * webView = self.webViewController.view;
        
        webView.frame = CGRectMake(0, 0,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height - (self.navigationController.navigationBar.frame.size.height + self.tabBarController.tabBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height));
        
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
}

- (void)configureViewForComment {
    NSLog(@"configureViewForComment stub");
    
    // Find root comment by traversing upwards
    [self.detailComment findStoryForComment:^(Story *story) {
        NSLog(@"root: %@", story);
        
        self.detailItem = story;
        [self.detailItem loadSpecificCommentForStory:
            self.detailComment.parent];
    }];
    
    // Find and instantiate immediate parent comment
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.contentSelectSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Comments", @"Story" ]];
    _contentSelectSegmentedControl.selectedSegmentIndex = 0;
    [_contentSelectSegmentedControl addTarget:self action:@selector(didSelectContentSegment:)
                             forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:_contentSelectSegmentedControl];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 1;
        
    } else {
        
        NSInteger commentCount = [_detailItem.flatDisplayComments count];
        if(commentCount == 0 && _initialLoadDone) {
            return 1;
            
        } else {
            return commentCount;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.section == 0) {
        StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                           kStoryCellReuseIdentifier forIndexPath:indexPath];
        
        cell.story = self.detailItem;
        cell.storyCellDelegate = self;
        
        return cell;
        
    } else {
        
        NSInteger commentCount = [_detailItem.flatDisplayComments count];
        
        if(commentCount == 0 && _initialLoadDone) {
            StoryCommentsNoCommentsCell * cell = [tableView dequeueReusableCellWithIdentifier:kNoCommentsReuseIdentifier forIndexPath:indexPath];
            return cell;
            
        } else {
            
            Comment * comment = _detailItem.flatDisplayComments[indexPath.row];
            
            CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier
                                                                 forIndexPath:indexPath];
            cell.comment = comment;
            
            cell.commentCellDelegate = self;
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 88.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        return [StoryCell heightForStoryCellWithStory:self.detailItem
                                                width:tableView.frame.size.width];

    } else {
        
        NSInteger commentCount = [_detailItem.flatDisplayComments count];
        if(commentCount == 0 && _initialLoadDone) {
            
            CGFloat headerHeight = [StoryCell heightForStoryCellWithStory:self.detailItem
                                                                    width:tableView.frame.size.width];
            return self.tableView.frame.size.height - headerHeight - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height;
            
        } else {
            Comment * comment = _detailItem.flatDisplayComments[indexPath.row];
            return [CommentCell heightForCommentCell:comment
                                               width:tableView.frame.size.width];
        }
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(indexPath.section == 0 && indexPath.row == 0) {
        self.contentSelectSegmentedControl.selectedSegmentIndex = 1;
        [self didSelectContentSegment:self.contentSelectSegmentedControl];
        
    } else {
        NSInteger commentCount = [_detailItem.flatDisplayComments count];
        if(commentCount > 0) {
            [self expandCollapseCommentForRow:indexPath];
        }
    }
}

#pragma mark - Private Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"showUser"]) {
        NSLog(@"prepareForSegue, showUser");
        
        __block UserViewController *controller = (UserViewController *)
            [[segue destinationViewController] topViewController];
        
        if(sender && [sender isKindOfClass:[NSString class]]) {
            controller.author = sender;
            
        } else if(sender && [sender isKindOfClass:[User class]]) {
            controller.user = sender;
        }
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    } else if([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSNumber * storyIdentifier = (NSNumber*)sender;
        
        StoryDetailViewController *controller = (StoryDetailViewController *)
            [[segue destinationViewController] topViewController];
        
        [Story createStoryFromItemIdentifier:storyIdentifier completion:^(Story *story) {
            controller.detailItem = story;
        }];
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

- (void)didSelectContentSegment:(id)sender {
    
    if(_contentSelectSegmentedControl.selectedSegmentIndex == 0) {
        
        if(_webViewController) {
            [_webViewController.view removeFromSuperview];
        }
        
    } else {
        
        if(_webViewController) {
            [self.view addSubview:self.webViewController.view];
        }
    }
}

- (void)commentCreated:(NSNotification*)notification {
    [self.baseTableView reloadData];
    
    if(self.loadingProgress.completedUnitCount < self.loadingProgress.totalUnitCount) {
        self.loadingProgress.completedUnitCount++;
    }
}

- (void)commentCollapsedComplete:(NSNotification*)notification {
    
    NSLog(@"commentCollapsedComplete");
    
    [self.baseTableView beginUpdates];
    [self.baseTableView endUpdates];
}

- (void)loadContent {
    
    if(!_detailItem) {
        return;
    }
    
    Story * detailStory = (Story*)_detailItem;
    if(!detailStory.kids || [detailStory.kids count] == 0) {
        
        _initialLoadDone = YES;
        
        self.tableView.scrollEnabled = NO;
        [self.tableView reloadData]; // Display no comments cell
        
    } else {

        self.tableView.scrollEnabled = YES;
        
        _initialLoadDone = NO;
        [detailStory loadCommentsForStory];
        
        self.loadingProgress = [NSProgress progressWithTotalUnitCount:
                                [detailStory.totalCommentCount intValue]];
        [self.loadingProgress addObserver:self forKeyPath:@"fractionCompleted"
                                  options:NSKeyValueObservingOptionNew context:NULL];
        
        NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                       delegate]).masterProgress;
        
        masterProgress.completedUnitCount = 0;
        masterProgress.totalUnitCount = [detailStory.totalCommentCount intValue];
        
        [masterProgress addChild:self.loadingProgress withPendingUnitCount:
         [detailStory.totalCommentCount intValue]];
    }
}

- (void)reloadContent:(id)sender {
    NSLog(@"reloadContent:");
    
    [self loadContent];
}

- (void)expandCollapseCommentForRow:(NSIndexPath *)indexPath {
    
    Comment * comment = _detailItem.flatDisplayComments[indexPath.row];
    
    NSArray * expandedCommentArray = [_detailItem.flatDisplayComments filteredArrayUsingPredicate:
        [NSPredicate predicateWithFormat:@"sizeStatus == %lu", CommentSizeStatusExpanded]];
    
    if([expandedCommentArray count] > 0) {
        Comment * expandedComment = [expandedCommentArray firstObject];
        expandedComment.sizeStatus = CommentSizeStatusNormal;
        
        // Job done, don't expand again
        if(comment == expandedComment) {
            [self.baseTableView beginUpdates];
            [self.baseTableView endUpdates];
            
            return;
        }
    }
    
    comment.sizeStatus = CommentSizeStatusExpanded;
    
    [self.baseTableView beginUpdates];
    [self.baseTableView endUpdates];
}

#pragma mark - CommentCellDelegate Methods
- (void)commentCell:(CommentCell*)cell didTapLink:(NSURL*)link {
    
    if([link isHNInternalLink]) {
        NSNumber * identifier = [link identifierForHNInternalLink];
        if(identifier) {
            [self performSegueWithIdentifier:@"showDetail" sender:identifier]; return;
        }
    } // Catches two else cases implicitly
    
    SFSafariViewController * controller = [[SFSafariViewController alloc]
                                           initWithURL:link];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)commentCell:(CommentCell*)cell didLongPressLink:(NSURL *)link {
    [CommentCell handleLongPressForLink:link inComment:cell.comment inController:self];
}

- (void)commentCell:(CommentCell*)cell didTapActionWithType:(NSNumber*)type {
    ActionDrawerViewButtonType actionType = [type intValue];

    if(actionType == ActionDrawerViewButtonTypeUser) {
        
        [self performSegueWithIdentifier:@"showUser"
                                  sender:cell.comment.author];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        
        [[self class] createShareActionSheetInController:self title:
         cell.comment.shareTitle url:cell.comment.hnPublicLink text:nil];
    }
}

#pragma mark - KVO Callback Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    NSNumber * fractionCompleted = change[NSKeyValueChangeNewKey];
    if([fractionCompleted floatValue] == 1.0f) {
        
        [self.baseRefreshControl endRefreshing];
        [self.loadingProgress removeObserver:self
                                  forKeyPath:@"fractionCompleted"];
        
        Story * detailStory = (Story*)_detailItem;
        [detailStory finishLoadingCommentsForStory];
        
        _initialLoadDone = YES;
    }
}

#pragma mark - SFSafariViewControllerDelegate Methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    self.contentSelectSegmentedControl.selectedSegmentIndex = 0;
    
    if(_webViewController) {
        [_webViewController.view removeFromSuperview];
    }
}

#pragma mark - StoryCellDelegate Methods
- (void)storyCellDidDisplayActionDrawer:(StoryCell*)cell {
    NSLog(@"storyCellDidDisplayActionDrawer");
}
- (void)storyCell:(StoryCell*)cell didTapActionWithType:(NSNumber*)type {
    [StoryCell handleActionForStory:cell.story withType:type inController:self];
}
- (void)storyCell:(StoryCell*)cell didTapLink:(NSURL*)link {
    
    if([link isHNInternalLink]) {
        NSNumber * identifier = [link identifierForHNInternalLink];
        if(identifier) {
            [self performSegueWithIdentifier:@"showDetail" sender:identifier]; return;
        }
    } // Catches two else cases implicitly
    
    SFSafariViewController * controller = [[SFSafariViewController alloc]
                                           initWithURL:link];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
