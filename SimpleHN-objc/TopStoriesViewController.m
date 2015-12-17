//
//  TopStoriesViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "TopStoriesViewController.h"

@interface TopStoriesViewController ()
- (void)didTapDebugItem:(id)sender;

@end

@implementation TopStoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Top";
    
//    UIBarButtonItem * debugItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
//                                   UIBarButtonSystemItemOrganize target:self action:@selector(didTapDebugItem:)];
//    
//    self.navigationItem .rightBarButtonItems = @[ _timePeriodItem, debugItem ];
    
    self.ref = [[Firebase alloc] initWithUrl:
                                        @"https://hacker-news.firebaseio.com/v0/topstories"];
    
    [self loadContent:nil];
    
    @weakify(self);
    [self addColorChangedBlock:^{
        @strongify(self);
        self.view.normalBackgroundColor = UIColorFromRGB(0xffffff);
        self.view.nightBackgroundColor = kNightDefaultColor;
    }];
}

#pragma mark - StoriesTimePeriodSelectViewController Methods
- (void)storiesTimePeriodSelectViewController:(StoriesTimePeriodSelectViewController*)controller
                  didChangeSelectedTimePeriod:(NSNumber*)period {
    
    [super storiesTimePeriodSelectViewController:controller didChangeSelectedTimePeriod:period];
    
    [[HNAlgoliaAPIManager sharedManager] loadTopStoriesWithTimePeriod:[period intValue] page:0 type:StoriesPageTypeTop completion:^(NSDictionary *result) {
        if(!result || ![[result allKeys] containsObject:kHNAlgoliaAPIManagerResults] || [result[kHNAlgoliaAPIManagerResults] count] == 0) {
            [self createErrorAlertWithTitle:@"Error" message:@"Unable to load stories for specified time period. Please check your connection and try again later."];
            return;
        }
        [self.selectedTimePeriodStories addObjectsFromArray:result[kHNAlgoliaAPIManagerResults]];
        [self.tableView reloadData];
        self.initialLoadDone = YES;
    }];
}

- (void)didTapDebugItem:(id)sender {
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:
                                      @"Debug" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"Load Comment" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        __block UITextField * textFieldRef = nil;
        
        UIAlertController * commentAlertController = [UIAlertController alertControllerWithTitle:
                                                      @"Enter Comment ID" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [commentAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Comment ID";
//            textField.text = @"10702042"; // User internal linking
            textField.text = @"10701973"; // User internal linking
            textFieldRef = textField;
        }];
        
        [commentAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            StoryDetailViewController * vc = (StoryDetailViewController *)
                [sb instantiateViewControllerWithIdentifier:@"StoryDetailViewController"];
            
            [Comment createCommentFromItemIdentifier:@([textFieldRef.text intValue]) completion:^(Comment *comment) {
                vc.detailComment = comment;
            }];
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }]];
        [commentAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:commentAlertController animated:YES completion:nil];

    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Load Story" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Load User" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
