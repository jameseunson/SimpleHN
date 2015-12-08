//
//  NSURL+HNInternalURL.m
//  SimpleHN-objc
//
//  Created by James Eunson on 8/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "NSURL+HNInternalURL.h"

@interface NSURL (HNInternalURLPrivate)
- (NSArray*)matchesForCandidateString;

@end

@implementation NSURL (HNInternalURL)

- (BOOL)isHNInternalLink {
    return ([[self matchesForCandidateString] count] > 0);
}

- (NSNumber*)identifierForHNInternalLink {

    if([self isHNInternalLink]) {
        
        @try {
            NSNumber * identifier = @([[[[self absoluteString] componentsSeparatedByString:@"?id="] lastObject] intValue]);
            return identifier;
        }
        @catch (NSException *exception) {
            NSLog(@"ERROR: Could not extract identifier from %@", [self absoluteString]);
        }
    }
    return nil;
}

- (NSArray*)matchesForCandidateString {
    NSString * internalLinkRegex = @"https?:\\/\\/news.ycombinator.com\\/item\\?id=([0-9]+)";
    
    NSError * error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:internalLinkRegex options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* matches = [regex matchesInString:[self absoluteString] options:0 range:NSMakeRange(0, [[self absoluteString] length])];
    
    return matches;
}

@end
