//
//  NSURL+HNInternalURL.h
//  SimpleHN-objc
//
//  Created by James Eunson on 8/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (HNInternalURL)

- (BOOL)isHNInternalLink;
- (BOOL)isHNInternalItemLink;
- (BOOL)isHNInternalUserLink;

- (NSNumber*)identifierForHNInternalItemLink;
- (NSString*)usernameForHNInternalUserLink;

@end
