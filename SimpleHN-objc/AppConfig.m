//
//  AppConfig.m
//  SimpleHN-objc
//
//  Created by James Eunson on 2/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "AppConfig.h"

#define kConfigStoreName @"SimpleHNConfig"

#define kConfigDefaultsDict @{ \
    kStoryAutomaticallyShowReader : @(YES), \
    kSearchRecentQueries : @[], \
    kSearchFilterTimePeriod : @(0), \
    kSearchFilterSortType : @(0), \
    kNightModeEnabled : @(NO), \
} \

@implementation AppConfig

+ (AppConfig *)sharedConfig
{
    static dispatch_once_t pred = 0;
    __strong static AppConfig *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)setDefaults {
    
    self.configDict = [[NSMutableDictionary alloc] init];
    self.configDict[kStoryAutomaticallyShowReader] = kConfigDefaultsDict[kStoryAutomaticallyShowReader];
    self.configDict[kSearchRecentQueries] = kConfigDefaultsDict[kSearchRecentQueries];
    self.configDict[kNightModeEnabled] = kConfigDefaultsDict[kNightModeEnabled];
    [self saveConfig];
}

- (void)setUpConfig {
    
    self.configDict = [[NSMutableDictionary alloc] initWithDictionary:
                   [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigStoreName]];
    
    if(!self.configDict || [[self.configDict allKeys] count] == 0) {
        self.configDict = [[NSMutableDictionary alloc] init];
        [self setDefaults];
    }
}

- (void)saveConfig {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.configDict forKey:kConfigStoreName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)storyAutomaticallyShowReader {
    if(![[self.configDict allKeys] containsObject:kStoryAutomaticallyShowReader]) {
        [self setBool:[kConfigDefaultsDict[kStoryAutomaticallyShowReader] boolValue] forKey:kStoryAutomaticallyShowReader];
    }
    return [self.configDict[kStoryAutomaticallyShowReader] boolValue];
}

- (NSArray*)searchRecentQueries {
    if(![[self.configDict allKeys] containsObject:kSearchRecentQueries]) {
        [self setObject:kConfigDefaultsDict[kSearchRecentQueries] forKey:kSearchRecentQueries];
    }
    return self.configDict[kSearchRecentQueries];
}

- (BOOL)nightModeEnabled {
    if(![[self.configDict allKeys] containsObject:kNightModeEnabled]) {
        [self setBool:[kConfigDefaultsDict[kNightModeEnabled] boolValue] forKey:kNightModeEnabled];
    }
    return [self.configDict[kNightModeEnabled] boolValue];
}

@end
