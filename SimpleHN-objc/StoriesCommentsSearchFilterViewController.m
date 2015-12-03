//
//  StoriesCommentSearchFilterViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 3/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoriesCommentsSearchFilterViewController.h"
#import "StoriesTimePeriodSelectViewController.h"

#define kTimePeriodCellReuseIdentifier @"timePeriodCellReuseIdentifier"

@interface StoriesCommentsSearchFilterViewController ()
- (void)cancelFilter:(id)sender;
- (void)didSelectFilter:(id)sender;

@end

@implementation StoriesCommentsSearchFilterViewController

- (instancetype)init {
    self = [super init];
    if(self) {
        _selectedPeriodIndex = 0;
        _lastPeriodSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.translucent = NO;
    
    // Preserve grouped style
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.tableView.frame
                                                          style:UITableViewStyleGrouped];
    self.tableView = tableView;
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kTimePeriodCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search Filter";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                              UIBarButtonSystemItemDone target:self action:@selector(didSelectFilter:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                             UIBarButtonSystemItemCancel target:self action:@selector(cancelFilter:)];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [kTimePeriods count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kTimePeriodCellReuseIdentifier forIndexPath:indexPath];
    
    NSMutableArray * modifiedTimePeriods = [kTimePeriods mutableCopy];
    
    [modifiedTimePeriods removeObject:[modifiedTimePeriods firstObject]];
    [modifiedTimePeriods insertObject:@(StoriesTimePeriodsNoPeriod) atIndex:0];
    
    cell.textLabel.text = kTimePeriodsLookup[modifiedTimePeriods[indexPath.row]];
    
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

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Time Period";
}

#pragma mark - Private Methods
- (void)cancelFilter:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectFilter:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
