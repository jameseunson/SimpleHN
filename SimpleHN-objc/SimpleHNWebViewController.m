//
//  StoryWebViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "SimpleHNWebViewController.h"

@interface SimpleHNWebViewController ()

@property (nonatomic, strong) WKWebView * webView;
//@property (nonatomic, strong) NSProgress * loadingProgress;

@property (nonatomic, strong) UIBarButtonItem * backButtonItem;
@property (nonatomic, strong) UIBarButtonItem * forwardButtonItem;
@property (nonatomic, strong) UIBarButtonItem * stopButtonItem;
@property (nonatomic, strong) UIBarButtonItem * refreshButtonItem;
@property (nonatomic, strong) UIBarButtonItem * shareButtonItem;
@property (nonatomic, strong) UIBarButtonItem * flexibleSpaceItem;

@property (nonatomic, strong) UIBarButtonItem * commentsItem;


- (void)didTapBackButtonItem:(id)sender;
- (void)didTapForwardButtonItem:(id)sender;
- (void)didTapStopButtonItem:(id)sender;
- (void)didTapRefreshButtonItem:(id)sender;
- (void)didTapShareButtonItem:(id)sender;
- (void)didTapCommentsIcon:(id)sender;

- (void)nightModeEvent:(NSNotification*)notification;

@end

@implementation SimpleHNWebViewController

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    self.webView = [[WKWebView alloc] init];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.navigationDelegate = self;
    
    [self.view addSubview:_webView];
    
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"V:|[_webView]|;H:|[_webView]|" options:0 metrics:nil views:
                               NSDictionaryOfVariableBindings(_webView)]];
    
    self.backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"story-webview-back-icon"] style:
                           UIBarButtonItemStylePlain target:self action:@selector(didTapBackButtonItem:)];
    _backButtonItem.enabled = NO;
    
    self.forwardButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"story-webview-forward-icon"] style:
                           UIBarButtonItemStylePlain target:self action:@selector(didTapForwardButtonItem:)];
    _forwardButtonItem.enabled = NO;
    
    self.stopButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"story-webview-stop-icon"] style:
                           UIBarButtonItemStylePlain target:self action:@selector(didTapStopButtonItem:)];
    
    self.refreshButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"story-webview-refresh-icon"] style:
                           UIBarButtonItemStylePlain target:self action:@selector(didTapRefreshButtonItem:)];
    
    self.shareButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"story-webview-share-icon"] style:
                           UIBarButtonItemStylePlain target:self action:@selector(didTapShareButtonItem:)];
    
    self.commentsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"story-web-comments-icon"] style:
                         UIBarButtonItemStylePlain target:self action:@selector(didTapCommentsIcon:)];
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.navigationController.toolbar.barTintColor = UIColorFromRGB(0x222222);
    } else {
        self.navigationController.toolbar.barTintColor = UIColorFromRGB(0xffffff);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionNightFallingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionDawnComingNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", _selectedStory.url);
    
    [_webView loadRequest:[NSURLRequest requestWithURL:_selectedStory.url]];
    self.title = _selectedStory.title;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress"
                              options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"canGoBack"
                      options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"canGoForward"
                      options:NSKeyValueObservingOptionNew context:NULL];

    
    self.navigationController.hidesBarsOnSwipe = YES;
    self.navigationController.toolbarHidden = NO;
    
    self.flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                           UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray * items = @[ _backButtonItem, _flexibleSpaceItem, _stopButtonItem, _flexibleSpaceItem,
                         _shareButtonItem, _flexibleSpaceItem, _forwardButtonItem ];
    [self.navigationController.visibleViewController setToolbarItems:items];
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    masterProgress.completedUnitCount = 0;
    masterProgress.totalUnitCount = 0;
    
    if(_selectedStory) {
        self.navigationItem.rightBarButtonItem = _commentsItem;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.toolbarHidden = YES;
    
    self.navigationController.toolbarItems = nil;
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    masterProgress.completedUnitCount = 0;
    masterProgress.totalUnitCount = 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqualToString:@"canGoBack"]) {
        
        BOOL canGoBack = [change[NSKeyValueChangeNewKey] boolValue];
        _backButtonItem.enabled = canGoBack;
        
    } else if([keyPath isEqualToString:@"canGoForward"]) {
        
        BOOL canGoForward = [change[NSKeyValueChangeNewKey] boolValue];
        _forwardButtonItem.enabled = canGoForward;
        
    } else if([keyPath isEqualToString:@"estimatedProgress"]) {
     
        NSNumber * fractionCompleted = change[NSKeyValueChangeNewKey];
        NSLog(@"observeValueForKeyPath, change: %@", change);
        
        NSInteger unitsCompleted = (NSInteger)roundf([fractionCompleted floatValue] * 100);
        if(unitsCompleted > 100) {
            unitsCompleted = 100;
        }
        NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                       delegate]).masterProgress;
        masterProgress.completedUnitCount = unitsCompleted;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"showDetail"]) {
        
        StoryDetailViewController *controller = (StoryDetailViewController *)
            [[segue destinationViewController] topViewController];
        [controller setDetailItem:sender];
        
        controller.navigationItem.leftBarButtonItem =
            self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - WKNavigationDelegate Methods
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"webView, didStartProvisionalNavigation: %@", navigation);
    
//    self.loadingProgress = [NSProgress progressWithTotalUnitCount:100];
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    masterProgress.totalUnitCount = 100;
    masterProgress.completedUnitCount = 0;
    
    NSArray * items = @[ _backButtonItem, _flexibleSpaceItem, _stopButtonItem, _flexibleSpaceItem,
                         _shareButtonItem, _flexibleSpaceItem, _forwardButtonItem ];
    [self.navigationController.visibleViewController setToolbarItems:items];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView, didFailProvisionalNavigation: %@, %@", navigation, error);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView, didFailNavigation: %@", error);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"webView, didCommitNavigation: %@", navigation);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"webView, didFinishNavigation: %@", navigation);
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    masterProgress.completedUnitCount = 100;
    
    NSArray * items = @[ _backButtonItem, _flexibleSpaceItem, _refreshButtonItem, _flexibleSpaceItem,
                         _shareButtonItem, _flexibleSpaceItem, _forwardButtonItem ];
    [self.navigationController.visibleViewController setToolbarItems:items];
}

#pragma mark - Private Methods
- (void)didTapBackButtonItem:(id)sender {
    
}

- (void)didTapForwardButtonItem:(id)sender {
    
}

- (void)didTapStopButtonItem:(id)sender {
    [self.webView stopLoading];
}

- (void)didTapRefreshButtonItem:(id)sender {
    [self.webView reload];
}

- (void)didTapShareButtonItem:(id)sender {
    
}

- (void)didTapCommentsIcon:(id)sender {
    [self performSegueWithIdentifier:@"showDetail" sender:self.selectedStory];
}

- (void)nightModeEvent:(NSNotification*)notification {
    
}

@end
