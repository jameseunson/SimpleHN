//
//  StoryWebViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "SimpleHNWebViewController.h"
#import "SimpleHNWebTitleSubtitleView.h"
#import "DZReadability.h"
#import "ContentLoadingView.h"

#define kLoadingText @"Loading..."

typedef NS_ENUM(NSInteger, SimpleHNWebViewControllerDisplayMode) {
    SimpleHNWebViewControllerDisplayModeNormal,
    SimpleHNWebViewControllerDisplayModeReader,
};

@interface SimpleHNWebViewController ()

@property (nonatomic, strong) WKWebView * webView;
@property (nonatomic, strong) WKWebView * readerWebView;

@property (nonatomic, strong) ContentLoadingView * readerContentLoadingView;

@property (nonatomic, strong) UIBarButtonItem * backButtonItem;
@property (nonatomic, strong) UIBarButtonItem * forwardButtonItem;
@property (nonatomic, strong) UIBarButtonItem * stopButtonItem;
@property (nonatomic, strong) UIBarButtonItem * refreshButtonItem;
@property (nonatomic, strong) UIBarButtonItem * shareButtonItem;
@property (nonatomic, strong) UIBarButtonItem * flexibleSpaceItem;

@property (nonatomic, strong) UIBarButtonItem * commentsItem;

@property (nonatomic, strong) UISegmentedControl * readerToggleSegmentedControl;
@property (nonatomic, strong) UIBarButtonItem * readerToggleBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * readerBeforeFixedSpaceItem;

@property (nonatomic, strong) SimpleHNWebTitleSubtitleView * titleView;

@property (nonatomic, strong) DZReadability * readability;

@property (nonatomic, assign) SimpleHNWebViewControllerDisplayMode displayMode;

- (void)didTapBackButtonItem:(id)sender;
- (void)didTapForwardButtonItem:(id)sender;
- (void)didTapStopButtonItem:(id)sender;
- (void)didTapRefreshButtonItem:(id)sender;
- (void)didTapShareButtonItem:(id)sender;
- (void)didTapCommentsIcon:(id)sender;

- (void)didChangeReaderToggleSegment:(id)sender;

- (void)nightModeEvent:(NSNotification*)notification;

- (void)createBarButtonItems;

@end

@implementation SimpleHNWebViewController
@synthesize displayMode = _displayMode;

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
    _webView.hidden = NO;
    [self.view addSubview:_webView];

    self.readerWebView = [[WKWebView alloc] init];
    _readerWebView.translatesAutoresizingMaskIntoConstraints = NO;
    _readerWebView.navigationDelegate = self;
    _readerWebView.hidden = YES;
    _readerWebView.scrollView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height +
                                                              [UIApplication sharedApplication].statusBarFrame.size.height,
                                                              0, self.tabBarController.tabBar.frame.size.height, 0);
    [self.view addSubview:_readerWebView];
    
    self.readerContentLoadingView = [[ContentLoadingView alloc] init];
    _readerContentLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
    _readerContentLoadingView.hidden = YES;
    [self.view addSubview:_readerContentLoadingView];

    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"V:|[_webView]|;H:|[_webView]|" options:0 metrics:nil views:
                               NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"V:|[_readerContentLoadingView]|;H:|[_readerContentLoadingView]|" options:0 metrics:nil views:
                               NSDictionaryOfVariableBindings(_readerContentLoadingView)]];
    [self.view addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                               @"V:|[_readerWebView]|;H:|[_readerWebView]|" options:0 metrics:nil views:
                               NSDictionaryOfVariableBindings(_readerWebView)]];
    
    [self createBarButtonItems];
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.navigationController.toolbar.barTintColor = UIColorFromRGB(0x222222);
    } else {
        self.navigationController.toolbar.barTintColor = UIColorFromRGB(0xffffff);
    }
    
    self.titleView = [[SimpleHNWebTitleSubtitleView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionNightFallingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                 name:DKNightVersionDawnComingNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(_selectedStory) {
        
        [_webView loadRequest:[NSURLRequest requestWithURL:_selectedStory.url]];
        
        _titleView.titleString = _selectedStory.title;
        _titleView.subtitleString = [_selectedStory.url absoluteString];
        
        self.navigationItem.rightBarButtonItem = _commentsItem;
        
        if([[AppConfig sharedConfig] storyAutomaticallyShowReader]) {
            self.displayMode = SimpleHNWebViewControllerDisplayModeReader;
            
        } else {
            self.displayMode = SimpleHNWebViewControllerDisplayModeNormal;
        }
        
    } else if(_selectedURL) {
        
        [_webView loadRequest:[NSURLRequest requestWithURL:_selectedURL]];
        
        _titleView.titleString = kLoadingText;
        _titleView.subtitleString = [_selectedURL absoluteString];
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    _titleView.frame = CGRectMake(0, 8, self.navigationController.navigationBar.frame.size.width - 88.0f, self.navigationController.navigationBar.frame.size.height - 16.0f);
    
    self.navigationItem.titleView = _titleView;
    
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
                         _shareButtonItem, _flexibleSpaceItem, _forwardButtonItem, _readerBeforeFixedSpaceItem,
                         _readerToggleBarButtonItem ];
    [self.navigationController.visibleViewController setToolbarItems:items];
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    masterProgress.completedUnitCount = 0;
    masterProgress.totalUnitCount = 0;
    
    NSURL * readabilityURL = nil;
    if(_selectedStory) {
        readabilityURL = _selectedStory.url;
        
    } else if(_selectedURL) {
        readabilityURL = _selectedURL;
    }
    
    self.readability = [[DZReadability alloc] initWithURLToDownload:readabilityURL options:nil
                                                  completionHandler:^(DZReadability *sender, NSString *content, NSError *error) {
        if (!error) {
            
            if(content && [content length] > 0) {
                
                NSString *templatePath = nil;
                if([[AppConfig sharedConfig] nightModeEnabled]) {
                    templatePath = [[NSBundle mainBundle] pathForResource:@"reader-night.template" ofType:@"html"];
                } else {
                    templatePath = [[NSBundle mainBundle] pathForResource:@"reader.template" ofType:@"html"];
                }
                NSString *templateHTML = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL];
                
                templateHTML = [templateHTML stringByReplacingOccurrencesOfString:@"READER_BODY" withString:content];
                
                if(_selectedStory) {
                    templateHTML = [templateHTML stringByReplacingOccurrencesOfString:@"READER_TITLE" withString:_selectedStory.title];
                    templateHTML = [templateHTML stringByReplacingOccurrencesOfString:@"READER_DOMAIN" withString:_selectedStory.url.host];
                    
                } else if(_selectedURL) {
                    templateHTML = [templateHTML stringByReplacingOccurrencesOfString:@"READER_TITLE" withString:_selectedURL.absoluteString];
                    templateHTML = [templateHTML stringByReplacingOccurrencesOfString:@"READER_DOMAIN" withString:_selectedURL.host];
                }
                
                [self.readerWebView loadHTMLString:templateHTML baseURL:
                 [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
                
            } else {
                // Could not parse, convert to normal
                self.displayMode = SimpleHNWebViewControllerDisplayModeNormal;
            }
            
            // handle returned content
        }
        else {
            // handle error
            self.displayMode = SimpleHNWebViewControllerDisplayModeNormal;
        }
    }];
    [self.readability start];
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
    
//    if(webView == _webView) {
//        _normalViewLoadStarted = YES;
//        
//    } else if(webView == _readerWebView) {
//        _readerViewLoadStarted = YES;
//    }
    
    if(webView.hidden) {
        return;
    }
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    masterProgress.totalUnitCount = 100;
    masterProgress.completedUnitCount = 0;
    
    NSArray * items = @[ _backButtonItem, _flexibleSpaceItem, _stopButtonItem, _flexibleSpaceItem,
                         _shareButtonItem, _flexibleSpaceItem, _forwardButtonItem, _readerBeforeFixedSpaceItem,
                         _readerToggleBarButtonItem ];
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
    
    if(webView == _readerWebView && !_readerContentLoadingView.hidden) {
        _readerContentLoadingView.hidden = YES;
    }
    
    if(webView == _webView && webView.title && (!_titleView.titleString || [_titleView.titleString isEqualToString:kLoadingText])) {
        _titleView.titleString = webView.title;
    }
    
    if(webView.hidden) {
        return;
    }
    
    NSProgress * masterProgress = ((AppDelegate *)[[UIApplication sharedApplication]
                                                   delegate]).masterProgress;
    masterProgress.completedUnitCount = 100;
    
    NSArray * items = @[ _backButtonItem, _flexibleSpaceItem, _refreshButtonItem, _flexibleSpaceItem,
                         _shareButtonItem, _flexibleSpaceItem, _forwardButtonItem, _readerBeforeFixedSpaceItem,
                         _readerToggleBarButtonItem ];
    [self.navigationController.visibleViewController setToolbarItems:items];
}

#pragma mark - Property Override Methods
- (void)setDisplayMode:(SimpleHNWebViewControllerDisplayMode)displayMode {
    _displayMode = displayMode;
    
    if(displayMode == SimpleHNWebViewControllerDisplayModeNormal) {
        _webView.hidden = NO;
        _readerWebView.hidden = YES;
        _readerContentLoadingView.hidden = YES;
        [_readerToggleSegmentedControl setSelectedSegmentIndex:0];
        
    } else {
        
        _webView.hidden = YES;
        _readerWebView.hidden = NO;
        _readerContentLoadingView.hidden = NO;
        [_readerToggleSegmentedControl setSelectedSegmentIndex:1];
    }
}

#pragma mark - Private Methods
- (void)createBarButtonItems {
    
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
    
    self.readerToggleSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"A", @"B" ]];
    
    _readerToggleSegmentedControl.frame = CGRectMake(0, 0, 70, 30);
    [_readerToggleSegmentedControl setImage:[[UIImage imageNamed:@"story-web-reader-selector-browser-icon"]
                                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forSegmentAtIndex:0];
    [_readerToggleSegmentedControl setImage:[[UIImage imageNamed:@"story-web-reader-selector-reader-icon"]
                                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forSegmentAtIndex:1];
    [_readerToggleSegmentedControl setSelectedSegmentIndex:0];    
    [_readerToggleSegmentedControl addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(didChangeReaderToggleSegment:)]];
    
    self.readerToggleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_readerToggleSegmentedControl];
    
    self.readerBeforeFixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil action:nil];
    [_readerBeforeFixedSpaceItem setWidth:16.0f];
}

- (void)didTapBackButtonItem:(id)sender {
    [self.webView goBack];
}

- (void)didTapForwardButtonItem:(id)sender {
    [self.webView goForward];
}

- (void)didTapStopButtonItem:(id)sender {
    [self.webView stopLoading];
}

- (void)didTapRefreshButtonItem:(id)sender {
    [self.webView reload];
}

- (void)didTapShareButtonItem:(id)sender {
    
    NSURL * shareURL = nil;
    if(_selectedStory) {
        shareURL = _selectedStory.url;
        
    } else if(_selectedURL) {
        shareURL = _selectedURL;
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:
                                            @[ shareURL ] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)didTapCommentsIcon:(id)sender {
    [self performSegueWithIdentifier:@"showDetail" sender:self.selectedStory];
}

- (void)didChangeReaderToggleSegment:(id)sender {
    NSLog(@"didChangeReaderToggleSegment:");
    
    if(_readerToggleSegmentedControl.selectedSegmentIndex == 0) {
        self.displayMode = SimpleHNWebViewControllerDisplayModeReader;
        
    } else {
        self.displayMode = SimpleHNWebViewControllerDisplayModeNormal;
    }
}

- (void)nightModeEvent:(NSNotification*)notification {
    
}

@end
