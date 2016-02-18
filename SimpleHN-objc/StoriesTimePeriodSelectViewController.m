//
//  StoriesTimePeriodSelectViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesTimePeriodSelectViewController.h"

#define kTimePeriodCellReuseIdentifier @"timePeriodCellReuseIdentifier"

@interface StoriesTimePeriodSelectViewController ()
- (void)didTapCancelItem:(id)sender;
@end

@implementation StoriesTimePeriodSelectViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _selectedPeriodIndex = 0;
    _lastPeriodSelected = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)loadView {
    [super loadView];
    
    [self.tableView registerClass:[UITableViewCell class]
        forCellReuseIdentifier:kTimePeriodCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.navigationController.navigationBar.barTintColor = kNightDefaultColor;
        self.view.backgroundColor = kNightDefaultColor;
        
    } else {
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xffffff);
        self.view.backgroundColor = UIColorFromRGB(0xffffff);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Select Time Period";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                             UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelItem:)];
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.navigationController.navigationBar.titleTextAttributes =
            @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
        
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
    } else {
        self.navigationController.navigationBar.titleTextAttributes =
            @{ NSForegroundColorAttributeName: [UIColor blackColor] };
        
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [kTimePeriods count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kTimePeriodCellReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = kTimePeriodsLookup[kTimePeriods[indexPath.row]];
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        cell.nightBackgroundColor = kNightDefaultColor;
        cell.textLabel.nightTextColor = UIColorFromRGB(0xffffff);
        
    } else {
        cell.backgroundColor = UIColorFromRGB(0xffffff);
        cell.textLabel.textColor = UIColorFromRGB(0x000000);
    }
    
    if(_selectedPeriodIndex == [indexPath row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedPeriodIndex = [indexPath row];
    [tableView cellForRowAtIndexPath:_lastPeriodSelected].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.lastPeriodSelected = indexPath;
    
    if([self.delegate respondsToSelector:@selector(storiesTimePeriodSelectViewController:didChangeSelectedTimePeriod:)]) {
        [self.delegate performSelector:@selector(storiesTimePeriodSelectViewController:didChangeSelectedTimePeriod:) withObject:self withObject:kTimePeriods[indexPath.row]];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private Methods
- (void)didTapCancelItem:(id)sender {
    if([self.delegate respondsToSelector:@selector(storiesTimePeriodSelectViewControllerDidCancelSelect:)]) {
        [self.delegate performSelector:@selector(storiesTimePeriodSelectViewControllerDidCancelSelect:) withObject:self];
    }
}

@end
