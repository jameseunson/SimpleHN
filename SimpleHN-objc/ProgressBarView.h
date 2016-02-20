//
//  ProgressBarView.h
//  SimpleHN-objc
//
//  Created by James Eunson on 19/02/2016.
//  Copyright © 2016 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBarView : UIView

@property (nonatomic, assign) float progress;

// Used for controller where UINavigationBar is translucent
// 0 y-coordinate is under navigation bar
@property (nonatomic, assign) CGFloat verticalOffset;

+ (ProgressBarView*)sharedProgressBarView;

@end
