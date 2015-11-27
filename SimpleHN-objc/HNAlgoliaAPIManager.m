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
    [self query:query withPage:1 withCompletion:completion];
}

- (void)query:(NSString*)query withPage:(NSInteger)pageNumber withCompletion: (void (^)(NSDictionary * result))completion {
    
    // If the passed query is not present the request is malformed, return
    if((!query || [query length] == 0)) return;
    
    NSString * searchURL = [NSString stringWithFormat: @"search?query=%@",
                            [query escapedQueryString]];
    
    [self.searchManager GET:searchURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"_searchManager, GET, response for query: %@, url: %@", query, searchURL);
        NSLog(@"responseObject: %@", responseObject);
        
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if(![[responseDict allKeys] containsObject:@"hits"] || ![responseDict[@"hits"] isKindOfClass:[NSArray class]]) {
            completion(nil); return;
        }
        NSArray * hits = responseDict[@"hits"];
        
        NSMutableArray * stories = [[NSMutableArray alloc] init];
        for(NSDictionary * hit in hits) {
            
            Story * story = [Story createStoryFromAlgoliaResult:hit];
            [stories addObject:story];
        }
        
        completion(@{ kHNAlgoliaAPIManagerResults: stories });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"_searchManager, ERROR: %@", error);
        completion(nil); return;
    }];
}

- (void)loadTopStoriesWithTimePeriod:(StoriesTimePeriods)period withCompletion: (void (^)(NSDictionary * result))completion {
    
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

@end
