//
//  AppConfigBase.h
//  SimpleHN-objc
//
//  Created by James Eunson on 2/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASKSettingsStore.h"

@interface AppConfigBase : NSObject <IASKSettingsStore>

@property (nonatomic, strong) NSMutableDictionary * configDict;

- (void)setDefaults;
- (void)saveConfig;
- (void)setUpConfig;

// Setters/getters required by IASKSettingsStore
- (void)setBool:(BOOL)value               forKey:(NSString*)key;
- (void)setDate:(NSDate*)date             forKey:(NSString*)key;
- (void)setDictionary:(NSDictionary*)dict forKey:(NSString*)key;
- (void)setFloat:(float)value             forKey:(NSString*)key;
- (void)setDouble:(double)value           forKey:(NSString*)key;
- (void)setObject:(id)object              forKey:(NSString*)key;
- (void)setInteger:(int)value             forKey:(NSString*)key;

- (BOOL)boolForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (int)integerForKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;

@end
