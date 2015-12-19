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
#define kHNAlgoliaAPIManagerTotalHits @"HNAlgoliaAPIManagerTotalHits"
#define kHNAlgoliaAPIManagerTotalPages @"HNAlgoliaAPIManagerTotalPages"
#define kHNAlgoliaAPIManagerCurrentPage @"HNAlgoliaAPIManagerCurrentPage"

typedef NS_ENUM(NSInteger, StoriesPageType) {
    StoriesPageTypeTop,
    StoriesPageTypeShowHN,
    StoriesPageTypeAskHN
};

@interface HNAlgoliaAPIManager : NSObject

+ (HNAlgoliaAPIManager*)sharedManager;

- (void)query:(NSString*)query withCompletion: (void (^)(NSDictionary * result))completion;
- (void)query:(NSString*)query withPage:(NSInteger)pageNumber withCompletion: (void (^)(NSDictionary * result))completion;
- (void)query:(NSString*)query withTimePeriod:(StoriesTimePeriods)period withPage:(NSInteger)pageNumber withCompletion: (void (^)(NSDictionary * result))completion;

- (void)loadTopStoriesWithTimePeriod:(StoriesTimePeriods)period page:(NSInteger)page type:(StoriesPageType)type completion: (void (^)(NSDictionary * result))completion;

- (void)pastDiscussionsForStory:(Story*)story completion:(void (^)(NSDictionary * result))completion;

@end
