//
//  SimpleHNSplitViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailViewController.h"

@interface SimpleHNSplitViewController : UISplitViewController

@property (nonatomic, strong) UITabBarController * tabBarController;
@property (nonatomic, strong) StoryDetailViewController * storyDetailViewController;

@end
