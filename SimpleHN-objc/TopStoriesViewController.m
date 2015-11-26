//
//  TopStoriesViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "TopStoriesViewController.h"

@interface TopStoriesViewController ()
- (UIFont*)extractDefaultNavigationBarFont;

@property (nonatomic, strong) NSNumber * selectedTimePeriod;
@property (nonatomic, strong) TopStoriesTitleView * titleView;

@end

@implementation TopStoriesViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedTimePeriod = [kTimePeriods firstObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Top";
    
    self.titleView = [[TopStoriesTitleView alloc] init];
    
    _titleView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width,
                                  self.navigationController.navigationBar.frame.size.height);
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleView.delegate = self;
    
    self.navigationItem.titleView = _titleView;
    
    self.ref = [[Firebase alloc] initWithUrl:
                                        @"https://hacker-news.firebaseio.com/v0/topstories"];
    [self loadStoryIdentifiersWithRef:self.ref];
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
    
    self.titleView.subtitleLabel.text = kTimePeriodsLookup[period];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)storiesTimePeriodSelectViewControllerDidCancelSelect:(StoriesTimePeriodSelectViewController*)controller {
    NSLog(@"storiesTimePeriodSelectViewControllerDidCancelSelect:");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TopStoriesTitleViewDelegate Methods
- (void)topStoriesTitleViewDidTapTitleView:(TopStoriesTitleView *)view {
    [self performSegueWithIdentifier:@"showTimePeriodSelect" sender:nil];    
}

#pragma mark - Private Methods
//- (void)didTapNavigationBar:(id)sender {
//    NSLog(@"didTapNavigationBar:");
//    
//    [self performSegueWithIdentifier:@"showTimePeriodSelect" sender:nil];
//}

- (UIFont*)extractDefaultNavigationBarFont {
    
    // Jump through some hoops to get the titleLabel font (semibold SF)
    UIFont * titleFont = [UIFont boldSystemFontOfSize:17.0f];
    
    for(UIView * subview in self.navigationController.navigationBar.subviews) {
        if([NSStringFromClass([subview class]) isEqualToString:@"UINavigationItemView"]) {
            for(UIView * view in subview.subviews) {
                if([view isKindOfClass:[UILabel class]]) {
                    titleFont = ((UILabel*)view).font;
                }
            }
        }
    }
    
    return titleFont;
}

@end
