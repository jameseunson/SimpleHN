//
//  HNAlgoliaAPIManager.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoriesTimePeriodSelectViewController.h"

#define kHNAlgoliaAPIManagerResults @"HNAlgoliaAPIManagerResults"

@interface HNAlgoliaAPIManager : NSObject

+ (HNAlgoliaAPIManager*)sharedManager;

- (void)query:(NSString*)query withCompletion: (void (^)(NSDictionary * result))completion;
- (void)query:(NSString*)query withPage:(NSInteger)pageNumber withCompletion: (void (^)(NSDictionary * result))completion;

- (void)loadTopStoriesWithTimePeriod:(StoriesTimePeriods)period withCompletion: (void (^)(NSDictionary * result))completion;

@end
