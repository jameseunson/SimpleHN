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

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)loadView {
    [super loadView];
    
    __block Firebase * topStoriesRef = [[Firebase alloc] initWithUrl:@"https://hacker-news.firebaseio.com/v0/topstories"];
    __block Firebase * baseRef = [[Firebase alloc] initWithUrl:@"https://hacker-news.firebaseio.com/v0/"];
    
    self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:topStoriesRef cellClass:[StoryCell class]
                                                   cellReuseIdentifier:kStoryCellReuseIdentifier view:self.tableView];
    
    [self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
        // Populate cell as you see fit, like as below
        cell.textLabel.text = [snap.value stringValue];
        
        NSString *itemId = [NSString stringWithFormat:@"item/%@", snap.value];
        Firebase * itemRef = [baseRef childByAppendingPath:itemId];
        
        [itemRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *itemSnap) {
            
            NSError * error = nil;
            Story * obj = [MTLJSONAdapter modelOfClass:Story.class
                                      fromJSONDictionary:itemSnap.value error:&error];
            NSLog(@"obj: %@", obj);
            
            StoryCell * storyCell = (StoryCell*)cell;
            storyCell.story = obj;
        }];
    }];
    
    [self.tableView setDataSource:self.dataSource];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
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
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
