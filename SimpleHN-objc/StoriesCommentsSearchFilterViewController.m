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
        
        _selectedPeriodIndex = [kSearchTimePeriods indexOfObject:@([[AppConfig sharedConfig] activeSearchFilter])];
        _lastPeriodSelected = [NSIndexPath indexPathForRow:[kSearchTimePeriods indexOfObject:
                                                            @([[AppConfig sharedConfig] activeSearchFilter])] inSection:0];
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
    
    @weakify(self);
    [self addColorChangedBlock:^{
        @strongify(self);
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xffffff);
        self.navigationController.navigationBar.nightBarTintColor = kNightDefaultColor;
        
        self.view.backgroundColor = UIColorFromRGB(0xffffff);
        self.view.nightBackgroundColor = kNightDefaultColor;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search Filter";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                              UIBarButtonSystemItemDone target:self action:@selector(didSelectFilter:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                             UIBarButtonSystemItemCancel target:self action:@selector(cancelFilter:)];
    
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
    return [kSearchTimePeriods count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kTimePeriodCellReuseIdentifier forIndexPath:indexPath];
    
    NSMutableArray * modifiedTimePeriods = [kSearchTimePeriods mutableCopy];
    
    [modifiedTimePeriods removeObject:[modifiedTimePeriods firstObject]];
    [modifiedTimePeriods insertObject:@(StoriesTimePeriodsNoPeriod) atIndex:0];
    
    cell.textLabel.text = kTimePeriodsLookup[modifiedTimePeriods[indexPath.row]];
    
    if(_selectedPeriodIndex == [indexPath row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    @weakify(cell);
    [self addColorChangedBlock:^{
        @strongify(cell);
        cell.backgroundColor = UIColorFromRGB(0xffffff);
        cell.nightBackgroundColor = kNightDefaultColor;
        
        cell.textLabel.textColor = UIColorFromRGB(0x000000);
        cell.textLabel.nightTextColor = UIColorFromRGB(0xffffff);
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedPeriodIndex = [indexPath row];
    [tableView cellForRowAtIndexPath:_lastPeriodSelected].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.lastPeriodSelected = indexPath;
    
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
    
    if([self.delegate respondsToSelector:@selector(storiesCommentsSearchFilterViewControllerDelegate:didSelectFilter:)]) {
        [self.delegate performSelector:@selector(storiesCommentsSearchFilterViewControllerDelegate:didSelectFilter:)
                            withObject:self withObject:kSearchTimePeriods[_lastPeriodSelected.row]];
    }
}

@end
