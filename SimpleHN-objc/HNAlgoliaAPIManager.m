//
//  HNAlgoliaAPIManager.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "HNAlgoliaAPIManager.h"
#import "AFHTTPSessionManager.h"
#import "NSString+EscapedURLString.h"
#import "Story.h"

static HNAlgoliaAPIManager * _sharedManager = nil;

@interface HNAlgoliaAPIManager ()

@property (nonatomic, strong, readonly) AFHTTPSessionManager * searchManager;

+ (NSDictionary*)processAlgoliaResponseDict:(NSDictionary*)responseDict;

+ (NSDate*)calculateStartPeriodDateForPeriod:(StoriesTimePeriods)period;

@end

@implementation HNAlgoliaAPIManager
@synthesize searchManager = _searchManager;

+ (HNAlgoliaAPIManager*)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HNAlgoliaAPIManager alloc] init];
    });
    return _sharedManager;
}

- (void)query:(NSString*)query withCompletion: (void (^)(NSDictionary * result))completion {
    [self query:query withTimePeriod:StoriesTimePeriodsNoPeriod withPage:0 withCompletion:completion];
}

- (void)query:(NSString*)query withPage:(NSInteger)pageNumber withCompletion: (void (^)(NSDictionary * result))completion {
    [self query:query withTimePeriod:StoriesTimePeriodsNoPeriod withPage:pageNumber withCompletion:completion];
}

- (void)query:(NSString*)query withTimePeriod:(StoriesTimePeriods)period withPage:(NSInteger)pageNumber withCompletion: (void (^)(NSDictionary * result))completion {
    // If the passed query is not present the request is malformed, return
    if((!query || [query length] == 0)) return;
    
    NSString * searchURL = [NSString stringWithFormat: @"search?tags=story&query=%@", query];
    
    if(pageNumber > 0) {
        searchURL = [NSString stringWithFormat:@"%@&page=%lu", searchURL, pageNumber];
    }
    if(period != StoriesTimePeriodsNoPeriod) {
        NSDate * startPeriodDate = [[self class] calculateStartPeriodDateForPeriod:period];
        searchURL = [NSString stringWithFormat:@"%@&numericFilters=created_at_i>%@", searchURL,
                     @((int)[startPeriodDate timeIntervalSince1970])];
    }
    NSString* urlStringEncoded = [searchURL stringByAddingPercentEncodingWithAllowedCharacters:
                                  [NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self.searchManager GET:urlStringEncoded parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"_searchManager, GET, response for query: %@, url: %@", query, searchURL);
        //        NSLog(@"responseObject: %@", responseObject);
        
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if(![[responseDict allKeys] containsObject:@"hits"] || ![responseDict[@"hits"] isKindOfClass:[NSArray class]]) {
            completion(nil); return;
        }
        
        completion([[self class] processAlgoliaResponseDict:responseDict]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"_searchManager, ERROR: %@", error);
        completion(nil); return;
    }];
}

- (void)loadTopStoriesWithTimePeriod:(StoriesTimePeriods)period page:(NSInteger)page type:(StoriesPageType)type completion: (void (^)(NSDictionary * result))completion {
    
    // https://hn.algolia.com/api/v1/search?tags=front_page,story&numericFilters=created_at_i%3E1450254334,created_at_i%3C1450340734
    
    NSString * pageTypeTag = nil;
    if(type == StoriesPageTypeTop) {
        pageTypeTag = @"story";
        
    } else if(type == StoriesPageTypeShowHN) {
        pageTypeTag = @"show_hn";
        
    } else if(type == StoriesPageTypeAskHN) {
        pageTypeTag = @"ask_hn";
    }
    
    NSString * urlStringTemplate = @"search?tags=%@&numericFilters=created_at_i>%@,created_at_i<%@&page=%@";
    NSDate * startPeriodDate = [[self class] calculateStartPeriodDateForPeriod:period];
    
    NSString * urlStringFormatted = [NSString stringWithFormat:urlStringTemplate, pageTypeTag, @((int)[startPeriodDate timeIntervalSince1970]),
                                     @((int)[[NSDate date] timeIntervalSince1970]), @(page)];
    NSString* urlStringEncoded = [urlStringFormatted stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self.searchManager GET:urlStringEncoded parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if(![[responseDict allKeys] containsObject:@"hits"] || ![responseDict[@"hits"] isKindOfClass:[NSArray class]]) {
            completion(nil); return;
        }
        
        completion([[self class] processAlgoliaResponseDict:responseDict]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"loadTopStoriesWithTimePeriod, ERROR: %@", error);
        completion(nil);
    }];
}

#pragma mark - Property Override Methods
- (AFHTTPSessionManager*)searchManager {
    if(_searchManager) {
        return _searchManager;
    }
    
    _searchManager = [[AFHTTPSessionManager alloc] initWithBaseURL:
                      [NSURL URLWithString:@"https://hn.algolia.com/api/v1/"]
                                              sessionConfiguration:
                      [NSURLSessionConfiguration defaultSessionConfiguration]];
    
    return _searchManager;
}

#pragma mark - Private Methods
+ (NSDictionary*)processAlgoliaResponseDict:(NSDictionary *)responseDict {
    
    NSArray * hits = responseDict[@"hits"];
    
    NSMutableArray * stories = [[NSMutableArray alloc] init];
    for(NSDictionary * hit in hits) {
        
        Story * story = [Story createStoryFromAlgoliaResult:hit];
        story.algoliaResult = YES;
        
        [stories addObject:story];
    }
    
    NSMutableDictionary * output = [@{ kHNAlgoliaAPIManagerResults: stories } mutableCopy];
    if([[responseDict allKeys] containsObject:@"nbHits"]) {
        output[kHNAlgoliaAPIManagerTotalHits] = responseDict[@"nbHits"];
    }
    if([[responseDict allKeys] containsObject:@"nbPages"]) {
        output[kHNAlgoliaAPIManagerTotalPages] = responseDict[@"nbPages"];
    }
    if([[responseDict allKeys] containsObject:@"page"]) {
        output[kHNAlgoliaAPIManagerCurrentPage] = responseDict[@"page"];
    }
    return output;
}

+ (NSDate*)calculateStartPeriodDateForPeriod:(StoriesTimePeriods)period {
    
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDate * startPeriodDate = nil;
    
    if(period == StoriesTimePeriodsLast24hrs) {
        startPeriodDate = [cal dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:[NSDate date] options:NSCalendarWrapComponents];
        
    } else if(period == StoriesTimePeriodsPastWeek) {
        startPeriodDate = [cal dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:[NSDate date] options:NSCalendarWrapComponents];
        
    } else if(period == StoriesTimePeriodsPastMonth) {
        startPeriodDate = [cal dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:[NSDate date] options:NSCalendarWrapComponents];
        
    } else if(period == StoriesTimePeriodsPastYear) {
        startPeriodDate = [cal dateByAddingUnit:NSCalendarUnitYear value:-1 toDate:[NSDate date] options:NSCalendarWrapComponents];
        
    } else if(period == StoriesTimePeriodsAllTime) {
        // TODO: Probably not correct, but oh well
        startPeriodDate = [cal dateByAddingUnit:NSCalendarUnitYear value:-5 toDate:[NSDate date] options:NSCalendarWrapComponents];
    }
    
    return startPeriodDate;
}

@end
