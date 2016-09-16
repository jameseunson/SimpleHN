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

@property (nonatomic, strong) UITextField * activeField;
@property (nonatomic, strong) NSMutableDictionary * fieldsLookup;

@end

@implementation LoginViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _username = @"";
    _password = @"";
    
    self.fieldsLookup = [[NSMutableDictionary alloc] init];
}

- (void)loadView {
    [super loadView];
    
    [self.tableView registerClass:[LoginFieldTableViewCell class]
           forCellReuseIdentifier:kLoginFieldTableViewCellReuseIdentifier];
    
    [self.tableView registerClass:[LoginButtonTableViewCell class]
           forCellReuseIdentifier:kLoginButtonTableViewCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f; // set to whatever your "average" cell height is
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xffffff);
    self.view.backgroundColor = RGBCOLOR(238, 238, 238);
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        LoginFieldTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:
                                          kLoginFieldTableViewCellReuseIdentifier forIndexPath:indexPath];
        if(indexPath.row == 0) {
            cell.type = LoginFieldTableViewCellTypeUsername;
        } else {
            cell.type = LoginFieldTableViewCellTypePassword;
        }
        cell.delegate = self;
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        _fieldsLookup[cell.field.placeholder] = cell.field;
        
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
    NSLog(@"processLogin");
    
    [[HNSessionAPIManager sharedManager] performLoginWithUsername:self.username password:self.password completion:^(NSDictionary *result) {
        NSLog(@"processLogin, result: %@", result);
    }];
}

#pragma mark - LoginFieldTableViewCell Delegate
- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didChangeText:(NSString*)text {
    
    if(cell.type == LoginFieldTableViewCellTypeUsername) {
        self.username = text;
    } else {
        self.password = text;
    }
}

- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didTapNextButton:(UIButton*)button {
    if(_activeField == _fieldsLookup[@"Username"]) {
        [_fieldsLookup[@"Password"] becomeFirstResponder];
    }
}
- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didTapPreviousButton:(UIButton*)button {
    if(_activeField == _fieldsLookup[@"Password"]) {
        [_fieldsLookup[@"Username"] becomeFirstResponder];
    }
}
- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didTapDoneButton:(UIButton*)button {
    [_activeField resignFirstResponder];
}

- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didStartEditing:(UITextField*)field {
    self.activeField = field;
    
    cell.prevBarButtonItem.enabled = ([cell.field.placeholder isEqualToString:@"Password"]);
    cell.nextBarButtonItem.enabled = ([cell.field.placeholder isEqualToString:@"Username"]);
}
- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didEndEditing:(UITextField*)field {
    [_activeField resignFirstResponder];
}

@end
