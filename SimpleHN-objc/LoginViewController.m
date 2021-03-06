//
//  LoginViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 15/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginButtonTableViewCell.h"

#define kLoginFieldTableViewCellReuseIdentifier @"loginFieldTableViewCellReuseIdentifier"
#define kLoginButtonTableViewCellReuseIdentifier @"loginButtonTableViewCellReuseIdentifier"

@interface LoginViewController ()

- (void)didTapLoginItem:(id)sender;
- (void)didTapCancelItem:(id)sender;

- (void)processLogin;

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;

@end

@implementation LoginViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _username = @"";
    _password = @"";
}

- (void)loadView {
    [super loadView];
    
    [self.tableView registerClass:[LoginFieldTableViewCell class]
           forCellReuseIdentifier:kLoginFieldTableViewCellReuseIdentifier];
    [self.tableView registerClass:[LoginButtonTableViewCell class]
           forCellReuseIdentifier:kLoginButtonTableViewCellReuseIdentifier];
    
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
    
    self.title = @"Login to HN";
    
    UIBarButtonItem * loginItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:
                                   UIBarButtonItemStylePlain target:self action:@selector(didTapLoginItem:)];
    self.navigationItem.rightBarButtonItem = loginItem;
    
    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                    UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelItem:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.navigationController.navigationBar.titleTextAttributes =
        @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
        
    } else {
        self.navigationController.navigationBar.titleTextAttributes =
        @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        
        LoginFieldTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:
                                          kLoginFieldTableViewCellReuseIdentifier forIndexPath:indexPath];
        if(indexPath.row == 0) {
            cell.type = LoginFieldTableViewCellTypeUsername;
        } else {
            cell.type = LoginFieldTableViewCellTypePassword;
        }
        cell.delegate = self;
        
        return cell;
        
    } else {
        
        LoginButtonTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:
                                           kLoginButtonTableViewCellReuseIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Login";
        return cell;
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1) {
        [self processLogin];
    }
}

#pragma mark - Private Methods
- (void)didTapLoginItem:(id)sender {
    NSLog(@"didTapLoginItem:");
    
    [self processLogin];
}

- (void)didTapCancelItem:(id)sender {
    NSLog(@"didTapCancelItem:");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)processLogin {
    
    [[HNSessionAPIManager sharedManager] performLoginWithUsername:self.username password:self.password completion:^(NSDictionary *result) {
        NSLog(@"processLogin, result: %@", result);
    }];
}

#pragma mark - LoginFieldTableViewCell Delegate
- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didChangeText:(NSString*)text {
    NSLog(@"text: %@", text);
    
    if(cell.type == LoginFieldTableViewCellTypeUsername) {
        self.username = text;
        
    } else {
        self.password = text;
    }
}

@end
