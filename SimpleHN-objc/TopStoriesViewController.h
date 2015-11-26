//
//  TopStoriesViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 10/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoriesViewController.h"
#import "StoriesTimePeriodSelectViewController.h"
#import "TopStoriesTitleView.h"

@interface TopStoriesViewController : StoriesViewController <StoriesTimePeriodSelectViewController,
    TopStoriesTitleViewDelegate>

@end
