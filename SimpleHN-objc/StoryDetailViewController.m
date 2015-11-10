//
//  DetailViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

@import SafariServices;

#import "StoryDetailViewController.h"
#import "Story.h"
#import "Comment.h"
#import "UserViewController.h"

#define kCommentCellReuseIdentifier @"kCommentCellReuseIdentifier"

@import WebKit;

@interface StoryDetailViewController ()

@property (nonatomic, strong) UISegmentedControl * contentSelectSegmentedControl;
@property (nonatomic, strong) SFSafariViewController * webViewController;

@property (nonatomic, strong) NSMutableArray * comments;
@property (nonatomic, strong) NSMutableArray * flatDisplayComments;

@property (nonatomic, strong) NSIndexPath * expandedCellIndexPath;

- (void)reloadContent:(id)sender;
- (void)didSelectContentSegment:(id)sender;

//- (void)commentCreated:(NSNotification*)notification;
//- (void)commentCreatedAux:(Comment*)comment indentation:(NSInteger)indentation;

- (void)commentCreated:(NSNotification*)notification;
- (void)commentCollapsedChanged:(NSNotification*)notification;

@end

@implementation StoryDetailViewController

#pragma mark - Managing the detail item

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
//    self.comments = [[NSMutableArray alloc] init];
//    self.flatDisplayComments = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCreated:)
                                                 name:kCommentCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCollapsedChanged:)
                                                 name:kCommentCollapsedChanged object:nil];
}

- (void)loadView {
    [super loadView];
    
//    self.tableView = [[UITableView alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[CommentCell class]
           forCellReuseIdentifier:kCommentCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
//    [self.view addSubview:_tableView];
    
//    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
//                               @"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
//                               @"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = RGBCOLOR(235, 235, 235);
    self.refreshControl.tintColor = [UIColor grayColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(reloadContent:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [_comments removeAllObjects];
        [_flatDisplayComments removeAllObjects];
        
        if(_webViewController) {
            [_webViewController.view removeFromSuperview];
            _webViewController = nil;
        }
        
        [self.tableView reloadData];
        
        // Update the view.
        [self configureView];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController
                                                        .navigationBar.frame.size.height, 0, 0, 0);
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (void)configureView {
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        Story * detailStory = (Story*)_detailItem;
        self.title = detailStory.title;
        
        if([detailStory.flatDisplayComments count] == 0) {
            [detailStory loadCommentsForStory];
        }
        
        if(!detailStory.url) {
            self.contentSelectSegmentedControl.enabled = NO;
        } else {
            self.contentSelectSegmentedControl.enabled = YES;
        }
    }
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
    return [_detailItem.flatDisplayComments count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Comment * comment = _detailItem.flatDisplayComments[indexPath.row];
    
    CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier
                                                         forIndexPath:indexPath];
    cell.comment = comment;
    if(_expandedCellIndexPath && [indexPath isEqual:_expandedCellIndexPath]) {
        cell.expanded = YES;
        
    } else {
        cell.expanded = NO;
    }
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark - Private Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"showUser"]) {
        NSLog(@"prepareForSegue, showUser");
        
        __block UserViewController *controller = (UserViewController *)
            [[segue destinationViewController] topViewController];
        controller.user = sender;
        
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
        
        if(!_webViewController) {
            if(!self.detailItem.url) {
                return;
            }
            
            self.webViewController = [[SFSafariViewController alloc] initWithURL:self.detailItem.url];
            [self addChildViewController:_webViewController];
            
            UIView * webView = self.webViewController.view;
            webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:webView];
            
        } else {
            [self.view addSubview:self.webViewController.view];
        }
    }
}

- (void)commentCreated:(NSNotification*)notification {
    [self.tableView reloadData];
}

- (void)commentCollapsedChanged:(NSNotification*)notification {
    [self.tableView reloadData];
}

- (void)reloadContent:(id)sender {
    NSLog(@"reloadContent:");
}

#pragma mark - CommentCellDelegate Methods
- (void)commentCell:(CommentCell*)cell didTapLink:(CommentLink*)link {
    
    SFSafariViewController * controller = [[SFSafariViewController alloc]
                                           initWithURL:link.url];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)commentCell:(CommentCell*)cell didTapActionWithType:(NSNumber*)type {
    ActionDrawerViewButtonType actionType = [type intValue];

    if(actionType == ActionDrawerViewButtonTypeUser) {
        NSLog(@"ActionDrawerViewButtonTypeUser");
        
        [cell.comment loadUserForComment:^(User *user) {
            [self performSegueWithIdentifier:@"showUser" sender:user];
        }];
    }
}

@end
