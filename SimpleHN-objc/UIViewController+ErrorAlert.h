//
//  UIViewController+ErrorAlert.h
//  SimpleHN-objc
//
//  Created by James Eunson on 17/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ErrorAlert)

- (void)createErrorAlertWithTitle:(NSString*)title message:(NSString*)message;

@end
