//
//  DetailViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "DetailViewController.h"
#import "Story.h"
#import "Comment.h"

@import WebKit;

@interface DetailViewController ()

@property (nonatomic, strong) UISegmentedControl * contentSelectSegmentedControl;
@property (nonatomic, strong) WKWebView * webView;

@property (nonatomic, strong) NSMutableArray * comments;
@property (nonatomic, strong) NSMutableArray * flatDisplayComments;

- (void)didSelectContentSegment:(id)sender;
- (void)commentCreated:(NSNotification*)notification;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    self.comments = [[NSMutableArray alloc] init];
    self.flatDisplayComments = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCreated:)
                                                 name:kCommentCreated object:nil];
}

- (void)loadView {
    [super loadView];
    
    self.webView = [[WKWebView alloc] init];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.hidden = YES;
    [self.view addSubview:_webView];
    
    self.tableView = [[UITableView alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
    [self.view addSubview:_tableView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_webView, _tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                               @"V:|[_webView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                               @"H:|[_webView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                               @"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                               @"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        Story * detailStory = (Story*)_detailItem;
        self.title = detailStory.title;
        
        NSString * storyURL = [NSString stringWithFormat:
                               @"https://hacker-news.firebaseio.com/v0/item/%@/kids",
                               detailStory.storyId];
        __block Firebase * commentsRef = [[Firebase alloc] initWithUrl:storyURL];
        
        [commentsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            for(FDataSnapshot * child in snapshot.children) {
                
                [Comment createCommentFromItemIdentifier:child.value completion:^(Comment *comment) {
                    
                    NSLog(@"DetailViewController, createCommentFromItemIdentifier, completion called: %@", comment);
                    
                    [self.comments addObject:comment];
                    [self.tableView reloadData];
                }];
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.contentSelectSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Comments", @"Story" ]];
    _contentSelectSegmentedControl.selectedSegmentIndex = 0;
    [_contentSelectSegmentedControl addTarget:self action:@selector(didSelectContentSegment:)
                             forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:_contentSelectSegmentedControl];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_flatDisplayComments count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"comment";
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

#pragma mark - Private Methods
- (void)didSelectContentSegment:(id)sender {
    NSLog(@"didSelectContentSegment:");
    
    if(_contentSelectSegmentedControl.selectedSegmentIndex == 0) {
        _webView.hidden = YES;
    } else {
        _webView.hidden = NO;
    }
}

- (void)commentCreated:(NSNotification*)notification {
    
    [_flatDisplayComments removeAllObjects];
    
    for(Comment * comment in _comments) {
        
    }
}

@end
