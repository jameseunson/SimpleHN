//
//  HNItemHelper.m
//  SimpleHN-objc
//
//  Created by James Eunson on 8/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "HNItemHelper.h"

@implementation HNItemHelper

+ (void)identifyHNItemWithNumber:(NSNumber*)number
                      completion:(HNItemHelperIdentificationResultBlock)completion {
    
    NSString * itemURL = [NSString stringWithFormat:
                             @"https://hacker-news.firebaseio.com/v0/item/%@", number];
    __block Firebase * itemRef = [[Firebase alloc] initWithUrl:itemURL];
    
    [itemRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        id value = snapshot.value;
        if([value isKindOfClass:[NSDictionary class]]) {
            HNItemHelperIdentificationResult result = [[self class]
                                                       identifyHNItemWithSnapshotDictionary:((NSDictionary*)value)];
            completion(result); return;
        }
        
        [itemRef removeAllObservers];
        
        NSLog(@"ERROR: HNItemHelper, response incorrectly formatted, result unknown");
        completion(HNItemHelperIdentificationResultUnknown);
    }];
}

+ (HNItemHelperIdentificationResult)identifyHNItemWithSnapshotDictionary:(NSDictionary*)dictionary {
    
    if([[dictionary allKeys] containsObject:@"type"] &&
       [dictionary[@"type"] isKindOfClass:[NSString class]] &&
       [dictionary[@"type"] length] > 0) {
        
        NSString * typeString = dictionary[@"type"];
        
        if([typeString isEqualToString:@"comment"]) {
            return HNItemHelperIdentificationResultComment;
            
        } else if([typeString isEqualToString:@"story"]) {
            return HNItemHelperIdentificationResultStory;
            
        } else {
            NSLog(@"ERROR: HNItemHelper, unrecognized type: %@", typeString);
        }
    }
    return HNItemHelperIdentificationResultUnknown;
}

@end
