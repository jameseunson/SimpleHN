//
//  UIViewController+ErrorAlert.m
//  SimpleHN-objc
//
//  Created by James Eunson on 17/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "UIViewController+ErrorAlert.h"

@implementation UIViewController (ErrorAlert)

- (void)createErrorAlertWithTitle:(NSString*)title message:(NSString*)message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
