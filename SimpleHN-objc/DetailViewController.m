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

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

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
        NSString * storyURL = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@/kids", detailStory.storyId];
        
        __block Firebase * baseRef = [[Firebase alloc] initWithUrl:@"https://hacker-news.firebaseio.com/v0/"];
        __block Firebase * commentsRef = [[Firebase alloc] initWithUrl:storyURL];
        
        self.dataSource = [[FirebaseTableViewDataSource alloc] initWithRef:commentsRef cellClass:[UITableViewCell class]
                                                       cellReuseIdentifier:@"reuseIdentifier" view:self.tableView];
        
        [self.dataSource populateCellWithBlock:^(UITableViewCell *cell, FDataSnapshot *snap) {
            // Populate cell as you see fit, like as below
            cell.textLabel.text = [snap.value stringValue];
            
            NSString *itemId = [NSString stringWithFormat:@"item/%@", snap.value];
            Firebase * itemRef = [baseRef childByAppendingPath:itemId];
            
            [itemRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *itemSnap) {

                NSError * error = nil;
                Comment * obj = [MTLJSONAdapter modelOfClass:Comment.class
                                        fromJSONDictionary:itemSnap.value error:&error];
                NSLog(@"obj: %@", obj);
                
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                
                cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
                
                cell.textLabel.text = obj.text;
                
//                NSError * error = nil;
//                Story * obj = [MTLJSONAdapter modelOfClass:Story.class
//                                        fromJSONDictionary:itemSnap.value error:&error];
//                NSLog(@"obj: %@", obj);
                
//                StoryCell * storyCell = (StoryCell*)cell;
//                storyCell.story = obj;
            }];
        }];
        
        [self.tableView setDataSource:self.dataSource];
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
