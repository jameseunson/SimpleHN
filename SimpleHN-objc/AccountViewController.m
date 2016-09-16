//
//  AccountTableViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 15/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "AccountViewController.h"
#import "UserEmptyView.h"
#import "JBNSLayoutConstraint+LinearEquation.h"

@interface AccountViewController () <UserEmptyViewDelegate>

@property (nonatomic, strong) UserEmptyView * emptyView;

@end

@implementation AccountViewController

- (void)loadView {
    [super loadView];
    
    self.emptyView = [[UserEmptyView alloc] init];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    _emptyView.delegate = self;
    [self.view addSubview:_emptyView];
    
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:@"V:|[_emptyView]|;H:|[_emptyView]|" options:
                               0 metrics:nil views:NSDictionaryOfVariableBindings(_emptyView)]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"User";
}

#pragma mark - UserEmptyViewDelegate Methods
- (void)userEmptyView:(UserEmptyView *)view didTapLoginButton:(UIButton *)button {
    NSLog(@"userEmptyView:didTapLoginButton:");
    
    [self performSegueWithIdentifier:@"showLogin" sender:nil];
}

@end
