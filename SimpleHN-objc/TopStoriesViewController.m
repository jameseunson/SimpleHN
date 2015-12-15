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
- (void)didTapDebugItem:(id)sender;

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
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
