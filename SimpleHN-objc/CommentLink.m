//
//  CommentLink.m
//  SimpleHN-objc
//
//  Created by James Eunson on 2/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "CommentLink.h"

@implementation CommentLink

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if(self) {
        if([[dict allKeys] containsObject:kCommentLinkText]) {
            self.text = dict[kCommentLinkText];
        }
        if([[dict allKeys] containsObject:kCommentLinkLabel]) {
            self.label = dict[kCommentLinkLabel];
        }
        if([[dict allKeys] containsObject:kCommentLinkStart]) {
            self.start = [dict[kCommentLinkStart] integerValue];
        }
        if([[dict allKeys] containsObject:kCommentLinkEnd]) {
            self.end = [dict[kCommentLinkEnd] integerValue];
        }
        if([[dict allKeys] containsObject:kCommentLinkUrl]) {
            self.url = dict[kCommentLinkUrl];
        }
    }
    return self;
}

@end
