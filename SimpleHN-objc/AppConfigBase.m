//
//  AppConfigBase.m
//  SimpleHN-objc
//
//  Created by James Eunson on 2/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "AppConfigBase.h"

@implementation AppConfigBase

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    [self setUpConfig];
    return self;
}

- (void)setDefaults {
    // overriden in subclass
}
- (void)saveConfig {
    // overriden in subclass
}
- (void)setUpConfig {
    // overriden in subclass
}

#pragma mark - IASKSettingsStore Methods
// Setters
- (void)setFloat:(float)value    forKey:(NSString*)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setDouble:(double)value  forKey:(NSString*)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setObject:(id)object forKey:(NSString*)key {
    _configDict[key] = object;
    [self saveConfig];
}
- (void)setInteger:(NSInteger)value forKey:(NSString*)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setBool:(BOOL)value forKey:(NSString *)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setDate:(NSDate*)date forKey:(NSString*)key {
    _configDict[key] = date;
    [self saveConfig];
}
- (void)setDictionary:(NSDictionary*)dict forKey:(NSString*)key {
    _configDict[key] = dict;
    [self saveConfig];
}

// Getters
- (BOOL)boolForKey:(NSString*)key {
    return [_configDict[key] boolValue];
}
- (float)floatForKey:(NSString*)key {
    return [_configDict[key] floatValue];
}
- (double)doubleForKey:(NSString*)key {
    return [_configDict[key] doubleValue];
}
- (int)integerForKey:(NSString*)key {
    return [_configDict[key] intValue];
}
- (id)objectForKey:(NSString*)key {
    return _configDict[key];
}

- (BOOL)synchronize {
    [self saveConfig];
    return YES;
}

@end
