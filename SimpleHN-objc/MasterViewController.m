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
#import "StoryLoadMoreCell.h"

#define kStoryCellReuseIdentifier @"storyCellReuseIdentifier"
#define kStoryLoadMoreCellReuseIdentifier @"storyLoadMoreCellReuseIdentifier"

@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray * storiesList;
@property (nonatomic, strong) NSMutableDictionary * storiesLoadStatus;
@property (nonatomic, strong) NSMutableDictionary * storiesLookup;

//@property (nonatomic, assign) NSInteger currentVisibleStoryMin;
@property (nonatomic, assign) NSInteger currentVisibleStoryMax;

@property (nonatomic, strong) UIRefreshControl * bottomRefreshControl;

- (void)reloadContent:(id)sender;

- (void)loadMoreStories:(id)sender;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    
//    _currentVisibleStoryMin = 0;
    _currentVisibleStoryMax = 20;
    
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
    [self.tableView registerClass:[StoryLoadMoreCell class]
           forCellReuseIdentifier:kStoryLoadMoreCellReuseIdentifier];
    
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
        [self loadVisibleStories];
        
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

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.tableView) {
        if(scrollView.contentOffset.y > (scrollView.contentSize.height - 44.0f)) {
            [_bottomRefreshControl beginRefreshing];
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger itemsCount = MIN(_currentVisibleStoryMax, [self.storiesList count]);
    if(itemsCount > 0) {
        itemsCount = itemsCount + 1;
    }
    return itemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == _currentVisibleStoryMax && [self.storiesList count] > 0) {
        
        StoryLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:
                           kStoryLoadMoreCellReuseIdentifier forIndexPath:indexPath];
        return cell;
        
    } else {
        
        StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:
                           kStoryCellReuseIdentifier forIndexPath:indexPath];
        
        NSNumber *storyIdentifier = self.storiesList[indexPath.row];
        
        if([[_storiesLookup allKeys] containsObject:storyIdentifier]) {
            cell.story = _storiesLookup[storyIdentifier];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == _currentVisibleStoryMax && [self.storiesList count] > 0) {
        [self loadMoreStories:nil];
        
    } else {
        
        StoryCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        self.detailViewController.detailItem = cell.story;
    }
}

- (void)reloadContent:(id)sender {
    
    // Simulated reload, TODO: Real reload
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Private Methods
- (void)loadVisibleStories {
    
    int i = 0;
    for(NSNumber * identifier in _storiesList) {
        
        if([_storiesLoadStatus[identifier] isEqual:@(StoryLoadStatusLoading)] ||
           [_storiesLoadStatus[identifier] isEqual:@(StoryLoadStatusLoaded)]) {
            i++; continue;
            
        } else {
         
            _storiesLoadStatus[identifier] = @(StoryLoadStatusNotLoaded);
            
            if(i < _currentVisibleStoryMax) {
                _storiesLoadStatus[identifier] = @(StoryLoadStatusLoading);
                [Story createStoryFromItemIdentifier:identifier completion:^(Story *story) {
                    
                    _storiesLookup[identifier] = story;
                    _storiesLoadStatus[identifier] = @(StoryLoadStatusLoaded);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }];
            }
        }
        i++;
    }
    
}
- (void)loadMoreStories:(id)sender {
    NSLog(@"loadMoreStories:");
    
    self.currentVisibleStoryMax += 20;
    [self loadVisibleStories];
}

@end
