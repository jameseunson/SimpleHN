//
//  SimpleHNNavigationController.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import "SimpleHNNavigationController.h"

@implementation SimpleHNNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        return UIStatusBarStyleLightContent;
        
    } else {
        return UIStatusBarStyleDefault;
    }
}

@end
