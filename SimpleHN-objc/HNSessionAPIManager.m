//
//  HNSessionAPIManager.m
//  SimpleHN-objc
//
//  Created by James Eunson on 15/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "HNSessionAPIManager.h"
#import "AFHTTPSessionManager.h"

static HNSessionAPIManager * _sharedManager = nil;

@interface HNSessionAPIManager ()

@property (nonatomic, strong, readonly) AFHTTPSessionManager * sessionManager;

@end

@implementation HNSessionAPIManager
@synthesize sessionManager = _sessionManager;

+ (HNSessionAPIManager*)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HNSessionAPIManager alloc] init];
    });
    return _sharedManager;
}

- (void)performLoginWithUsername:(NSString*)username password:(NSString*)password completion: (void (^)(NSDictionary * result))completion {
    
    NSArray *cookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:
                              [NSURL URLWithString:@"https://news.ycombinator.com"]];
    
    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieStorage];
    NSLog(@"%@", cookieHeaders);
    
    if([cookieStorage count] > 0) {
        NSHTTPCookie * cookie = [cookieStorage firstObject];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    NSDictionary * params = @{ @"acct": username, @"pw": password, @"goto": @"news" };
    NSLog(@"params: %@", params);
    
    [self.sessionManager POST:@"login?goto=news" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
        
        NSString * responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", responseString);
        
        NSArray * postRequestCookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:
                                              [NSURL URLWithString:@"https://news.ycombinator.com"]];
        NSDictionary * postRequestCookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:postRequestCookieStorage];
        NSLog(@"%@", postRequestCookieHeaders);
        
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        completion(nil);
    }];
}

#pragma mark - Property Override Methods
- (AFHTTPSessionManager*)sessionManager {
    if(_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:
                      [NSURL URLWithString:@"https://news.ycombinator.com"]
                                              sessionConfiguration:
                      [NSURLSessionConfiguration defaultSessionConfiguration]];
    
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return _sessionManager;
}

@end
