//
//  CommentStyle.m
//  SimpleHN-objc
//
//  Created by James Eunson on 23/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "CommentStyle.h"

@implementation CommentStyle

//- (instancetype)initWithDictionary:(NSDictionary*)dict {
//    self = [super init];
//    if(self) {
//        if([[dict allKeys] containsObject:kCommentStyleType]) {
//            self.type = [dict[kCommentStyleType] intValue];
//        }
//        if([[dict allKeys] containsObject:kCommentStyleStart]) {
//            self.start = [dict[kCommentStyleStart] integerValue];
//        }
//        if([[dict allKeys] containsObject:kCommentStyleEnd]) {
//            self.end = [dict[kCommentStyleEnd] integerValue];
//        }
//        if([[dict allKeys] containsObject:kCommentStyleText]) {
//            self.text = dict[kCommentStyleText];
//        }
//    }
//    return self;
//}

+ (NSString*)openTagForType:(CommentStyleType)type {
    if(type == CommentStyleTypeItalic) {
        return @"<i>";
        
    } else if(type == CommentStyleTypeBold) {
        return @"<b>";
        
    } else if(type == CommentStyleTypeQuote) {
        //        return @"\n>|^>"; // regex
        return @"^&gt;|<p>&gt;"; // regex
        
    } else if(type == CommentStyleTypeMultiQuote) {
        return @"<p><pre><code>[ ]+&gt;";
        
    } else if(type == CommentStyleTypeCode) {
        return @"<pre><code>";
    }
    return nil;
}
+ (NSString*)closeTagForType:(CommentStyleType)type {
    if(type == CommentStyleTypeItalic) {
        return @"</i>";
        
    } else if(type == CommentStyleTypeBold) {
        return @"</b>";
        
        // Missing: CommentStyleTypeQuote
        // Reason: has no close tag, either next present \n or EOF
        
    } else if(type == CommentStyleTypeCode) {
        return @"</code></pre>";
    }
    return nil;
}

//+ (CommentStyle*)styleWithType:(CommentStyleType)type start:(NSInteger)start
//                           end:(NSInteger)end text:(NSString*)text {
//    
//    NSDictionary * styleDict = @{ kCommentStyleType: @(type),
//                                  kCommentStyleText: text,
//                                  kCommentStyleStart: @(start),
//                                  kCommentStyleEnd: @(end) };
//    
//    CommentStyle * style = [[CommentStyle alloc] initWithDictionary:styleDict];
//    return style;
//}

@end
