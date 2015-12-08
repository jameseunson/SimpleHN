//
//  HNItemHelper.h
//  SimpleHN-objc
//
//  Created by James Eunson on 8/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//
//  Class that helps determine whether a HN object id
//  points to a story or comment. Probably in future
//  will be expanded to identifiy polls, etc

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HNItemHelperIdentificationResult) {
    HNItemHelperIdentificationResultUnknown = 0,
    HNItemHelperIdentificationResultStory = 1,
    HNItemHelperIdentificationResultComment = 2
};

typedef void (^HNItemHelperIdentificationResultBlock)(HNItemHelperIdentificationResult identification);

@interface HNItemHelper : NSObject

+ (void)identifyHNItemWithNumber:(NSNumber*)number
                      completion:(HNItemHelperIdentificationResultBlock)completion;
+ (HNItemHelperIdentificationResult)identifyHNItemWithSnapshotDictionary:(NSDictionary*)dictionary;

@end
