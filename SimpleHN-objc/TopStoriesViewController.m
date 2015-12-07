//
//  TopStoriesViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "TopStoriesViewController.h"

@interface TopStoriesViewController ()

- (void)didTapTimePeriodItem:(id)sender;

@property (nonatomic, strong) UIBarButtonItem * timePeriodItem;
@property (nonatomic, strong) NSNumber * selectedTimePeriod;

@end

@implementation TopStoriesViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedTimePeriod = [kTimePeriods firstObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Top";
    
    self.timePeriodItem = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:
                           UIBarButtonItemStylePlain target:self action:@selector(didTapTimePeriodItem:)];
    self.navigationItem.rightBarButtonItem = _timePeriodItem;
    
    self.ref = [[Firebase alloc] initWithUrl:
                                        @"https://hacker-news.firebaseio.com/v0/topstories"];
    
    [self loadContent:nil];
    
    @weakify(self);
    [self addColorChangedBlock:^{
        @strongify(self);
        self.tableView.normalBackgroundColor = UIColorFromRGB(0xffffff);
        self.tableView.nightBackgroundColor = UIColorFromRGB(0x343434);
    }];
    
//    [DKNightVersionManager nightFalling];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showTimePeriodSelect"]) {
        
        StoriesTimePeriodSelectViewController *controller = (StoriesTimePeriodSelectViewController *)
            [[segue destinationViewController] topViewController];
        controller.delegate = self;

    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

#pragma mark - StoriesTimePeriodSelectViewController Methods
- (void)storiesTimePeriodSelectViewController:(StoriesTimePeriodSelectViewController*)controller
                  didChangeSelectedTimePeriod:(NSNumber*)period {
    NSLog(@"storiesTimePeriodSelectViewController:didChangeSelectedTimePeriod:");
    
//    self.titleView.subtitleLabel.text = kTimePeriodsLookup[period];
    self.timePeriodItem.title = kTimePeriodsLookup[period];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)storiesTimePeriodSelectViewControllerDidCancelSelect:(StoriesTimePeriodSelectViewController*)controller {
    NSLog(@"storiesTimePeriodSelectViewControllerDidCancelSelect:");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods


- (void)didTapTimePeriodItem:(id)sender {
    [self performSegueWithIdentifier:@"showTimePeriodSelect" sender:nil];
}

@end
