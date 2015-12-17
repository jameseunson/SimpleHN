//
//  StoryWebViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 17/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPNavBarSqueezableViewController.h"

@import WebKit;

@interface SimpleHNWebViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic, strong) Story * selectedStory;

//@property (nonatomic, strong)

@end
