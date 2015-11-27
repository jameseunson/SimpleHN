//
//  StoriesCommentsSearchResultsViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 18/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsSearchResultsViewController.h"

@interface StoriesCommentsSearchResultsViewController ()

@property (nonatomic, strong) NSMutableArray < NSNumber * > * storiesList;

@end

@implementation StoriesCommentsSearchResultsViewController

- (instancetype)init {
    if(self = [super init]) {
        self.storiesList = [[NSMutableArray alloc] init];
        
        [super awakeFromNib];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == self.currentVisibleItemMax && [self.storiesList count] > 0) {
        [self loadMoreItems];
        
    } else {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    }
}

- (void)addSearchResults:(NSArray*)results {
    
    int i = 0;
    for(Story * story in results) {
        
        self.itemsLookup[story.storyId] = story;
        self.itemsLoadStatus[story.storyId] = @(StoryLoadStatusLoaded);
        [self.visibleItems addObject:story.storyId];
        
        i++;
    }
    [self.tableView reloadData];
    
    if(!self.loadingView.hidden) {
        self.loadingView.hidden = YES;
    }
}

@end
