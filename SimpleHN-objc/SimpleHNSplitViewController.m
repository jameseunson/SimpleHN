//
//  SimpleHNSplitViewController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "SimpleHNSplitViewController.h"

@implementation SimpleHNSplitViewController

- (void)showDetailViewController:(UIViewController *)vc sender:(nullable id)sender {

    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        
        UITabBarController * tabBarController = [self.viewControllers firstObject];
        UINavigationController * navigationController = tabBarController.selectedViewController;
        
        if([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController * enclosingNavigationController = (UINavigationController*)vc;
            vc = [enclosingNavigationController topViewController];
        }
        
        [navigationController showViewController:vc sender:sender];
        return;
    }
    
    [super showDetailViewController:vc sender:sender];
}

@end
