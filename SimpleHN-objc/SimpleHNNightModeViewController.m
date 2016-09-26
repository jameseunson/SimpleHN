//
//  SimpleHNNightModeViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "SimpleHNNightModeViewController.h"

@implementation SimpleHNNightModeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    [self updateNightMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionNightFallingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionDawnComingNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nightToggleItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"day-night-toggle-night"]
                                                            style:UIBarButtonItemStylePlain target:self action:@selector(toggleNightMode:)];
    self.navigationItem.rightBarButtonItem = _nightToggleItem;
}

#pragma mark - Private Methods
- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}

- (void)toggleNightMode:(id)sender {
    
    [[AppConfig sharedConfig] setBool:![[AppConfig sharedConfig] nightModeEnabled]
                               forKey:kNightModeEnabled];
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [UIView animateWithDuration:0.3 animations:^{
        [delegate updateNightMode];
    }];
    [self.navigationItem setRightBarButtonItem:_nightToggleItem animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)updateNightMode {
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        
        self.navigationController.navigationBar.barTintColor = self.tabBarController.tabBar.barTintColor
        = self.view.backgroundColor = kNightDefaultColor;
        
        self.navigationController.navigationBar.titleTextAttributes =
        @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
        
    } else {
        
        self.navigationController.navigationBar.barTintColor = self.tabBarController.tabBar.barTintColor
        = self.view.backgroundColor = UIColorFromRGB(0xffffff);
        
        self.navigationController.navigationBar.titleTextAttributes =
        @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    }
}

@end
