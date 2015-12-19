//
//  MasterViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firebase.h"
#import "StoryCell.h"
#import "StoriesCommentsBaseViewController.h"
#import "IASKAppSettingsViewController.h"
#import "StoriesTimePeriodSelectViewController.h"

@class StoryDetailViewController;

@interface StoriesViewController : StoriesCommentsBaseViewController <IASKSettingsDelegate, StoriesTimePeriodSelectViewController, UISplitViewControllerDelegate>

@property (nonatomic, strong) Firebase * ref;
@property (nonatomic, strong) NSMutableArray * storiesList;

@property (nonatomic, assign) StoryType storyType;

@property (nonatomic, assign) StoriesTimePeriods selectedTimePeriod;
@property (nonatomic, strong) NSMutableArray * selectedTimePeriodStories;

@property (strong, nonatomic) StoryDetailViewController *detailViewController;

//- (void)loadStoryIdentifiersWithRef:(Firebase *)ref;
- (void)didTapSettingsIcon:(id)sender;

@end

