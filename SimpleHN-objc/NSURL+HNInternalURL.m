//
//  NSURL+HNInternalURL.m
//  SimpleHN-objc
//
//  Created by James Eunson on 8/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "NSURL+HNInternalURL.h"

#define kInternalItemLinkRegex @"https?:\\/\\/news.ycombinator.com\\/item\\?id=([0-9]+)"
#define kInternalUserLinkRegex @"https?:\\/\\/news.ycombinator.com\\/user\\?id=([a-zA-Z0-9]+)"

@interface NSURL (HNInternalURLPrivate)
- (NSArray*)matchesForItemRegex;
- (NSArray*)matchesForUserRegex;

@end

@implementation NSURL (HNInternalURL)

- (BOOL)isHNInternalLink {
    return ([[self matchesForItemRegex] count] > 0) || ([[self matchesForUserRegex] count] > 0);
}

- (BOOL)isHNInternalItemLink {
    return ([[self matchesForItemRegex] count] > 0);
}

- (BOOL)isHNInternalUserLink {
    return ([[self matchesForUserRegex] count] > 0);
}

- (NSNumber*)identifierForHNInternalItemLink {

    if([self isHNInternalItemLink]) {
        
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

- (NSString*)usernameForHNInternalUserLink {
    
    if([self isHNInternalUserLink]) {
        
        @try {
            return [[[self absoluteString] componentsSeparatedByString:@"?id="] lastObject];
        }
        @catch (NSException *exception) {
            NSLog(@"ERROR: Could not extract username from %@", [self absoluteString]);
        }
    }
    return nil;
}

- (NSArray*)matchesForItemRegex {
    
    NSError * error = nil;
    NSArray* itemMatches = [[NSRegularExpression regularExpressionWithPattern:kInternalItemLinkRegex options:NSRegularExpressionCaseInsensitive error:&error] matchesInString:[self absoluteString] options:0 range:NSMakeRange(0, [[self absoluteString] length])];
    
    return itemMatches;
}
- (NSArray*)matchesForUserRegex {
    
    NSError * error = nil;
    NSArray* userMatches = [[NSRegularExpression regularExpressionWithPattern:kInternalUserLinkRegex options:NSRegularExpressionCaseInsensitive error:&error] matchesInString:[self absoluteString] options:0 range:NSMakeRange(0, [[self absoluteString] length])];
    
    return userMatches;
}

@end
