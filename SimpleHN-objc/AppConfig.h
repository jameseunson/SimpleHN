//
//  AppConfig.h
//  SimpleHN-objc
//
//  Created by James Eunson on 2/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConfigBase.h"

// Configuration keys
#define kStoryAutomaticallyShowReader @"storyAutomaticallyShowReader"
#define kSearchRecentQueries @"searchRecentQueries"

#define kSearchFilterTimePeriod @"searchFilterTimePeriod"
#define kSearchFilterSortType @"searchFilterSortType"

#define kNightModeEnabled @"nightModeEnabled"

@interface AppConfig : AppConfigBase

+ (AppConfig *)sharedConfig;

- (BOOL)storyAutomaticallyShowReader;
- (NSArray*)searchRecentQueries;

- (BOOL)nightModeEnabled;

@end
