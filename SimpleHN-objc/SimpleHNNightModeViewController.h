//
//  SimpleHNNightModeViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleHNNightModeViewController : UIViewController

@property (nonatomic, strong) UIBarButtonItem * nightToggleItem;

@property (nonatomic, strong) UIColor * defaultSeparatorColor;

- (void)toggleNightMode:(id)sender;
- (void)nightModeEvent:(NSNotification*)notification;

- (void)updateNightMode;

@end
