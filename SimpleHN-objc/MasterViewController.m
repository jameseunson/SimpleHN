//
//  MasterViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Story.h"
#import "StoryCell.h"

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"

@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray * storiesList;
@property (nonatomic, strong) NSMutableDictionary * storiesLoadStatus;
@property (nonatomic, strong) NSMutableDictionary * storiesLookup;

- (void)reloadContent:(id)sender;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    self.storiesList = [[NSMutableArray alloc] init];
    self.storiesLoadStatus = [[NSMutableDictionary alloc] init];
    self.storiesLookup = [[NSMutableDictionary alloc] init];
}

- (void)loadView {
    [super loadView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[StoryCell class]
           forCellReuseIdentifier:kStoryCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = RGBCOLOR(235, 235, 235);
    self.refreshControl.tintColor = [UIColor grayColor];
    
    [self.refreshControl addTarget:self
                            action:@selector(reloadContent:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController
                                                          .viewControllers lastObject] topViewController];
    self.title = @"Top Stories";
    
    __block Firebase * topStoriesRef = [[Firebase alloc] initWithUrl:
                                        @"https://hacker-news.firebaseio.com/v0/topstories"];
    
    [self.refreshControl beginRefreshing];
    
    [topStoriesRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.storiesList addObjectsFromArray:snapshot.value];
        
        for(NSNumber * identifier in _storiesList) {
            _storiesLoadStatus[identifier] = @(StoryLoadStatusNotLoaded);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        id object = self.storiesList[indexPath.row];
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.storiesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kStoryCellReuseIdentifier forIndexPath:indexPath];

    NSNumber *storyIdentifier = self.storiesList[indexPath.row];
    
    if([_storiesLoadStatus[storyIdentifier] integerValue] == StoryLoadStatusNotLoaded) {
        
        _storiesLoadStatus[storyIdentifier] = @(StoryLoadStatusLoading);
        
        __block StoryCell * blockCell = cell;
        [Story createStoryFromItemIdentifier:storyIdentifier completion:^(Story *story) {
            
            _storiesLookup[storyIdentifier] = story;
            _storiesLoadStatus[storyIdentifier] = @(StoryLoadStatusLoaded);
            
            blockCell.story = story;
            [blockCell setNeedsLayout];
        }];
        
    } else if([_storiesLoadStatus[storyIdentifier] integerValue] == StoryLoadStatusNotLoaded) {
        
        cell.story = _storiesLookup[storyIdentifier];
        [cell setNeedsLayout];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StoryCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    self.detailViewController.detailItem = cell.story;
}

- (void)reloadContent:(id)sender {
    
}

@end
