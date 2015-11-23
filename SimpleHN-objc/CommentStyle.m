//
//  CommentStyle.m
//  SimpleHN-objc
//
//  Created by James Eunson on 23/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "CommentStyle.h"

@implementation CommentStyle

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if(self) {
        if([[dict allKeys] containsObject:kCommentStyleType]) {
            self.type = [dict[kCommentStyleType] intValue];
        }
        if([[dict allKeys] containsObject:kCommentStyleStart]) {
            self.start = [dict[kCommentStyleStart] integerValue];
        }
        if([[dict allKeys] containsObject:kCommentStyleEnd]) {
            self.end = [dict[kCommentStyleEnd] integerValue];
        }
        if([[dict allKeys] containsObject:kCommentStyleText]) {
            self.text = dict[kCommentStyleText];
        }
    }
    return self;
}

+ (NSString*)openTagForType:(CommentStyleType)type {
    if(type == CommentStyleTypeItalic) {
        return @"<i>";
    } else if(type == CommentStyleTypeBold) {
        return @"<b>";
    }
    return nil;
}
+ (NSString*)closeTagForType:(CommentStyleType)type {
    if(type == CommentStyleTypeItalic) {
        return @"</i>";
    } else if(type == CommentStyleTypeBold) {
        return @"</b>";
    }
    return nil;
}

@end
