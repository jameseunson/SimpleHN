//
//  CommentStyle.h
//  SimpleHN-objc
//
//  Created by James Eunson on 23/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCommentStyleType @"commentStyleType"
#define kCommentStyleStart @"commentStyleStart"
#define kCommentStyleEnd @"commentStyleEnd"
#define kCommentStyleText @"commentStyleText"

typedef NS_ENUM(NSInteger, CommentStyleType) {
    CommentStyleTypeBold,
    CommentStyleTypeItalic,
    CommentStyleTypeQuote,
    CommentStyleTypeMultiQuote,
    CommentStyleTypeCode
};

@interface CommentStyle : NSObject

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@property (nonatomic, strong) NSString * text;

@property (nonatomic, assign) CommentStyleType type;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

+ (NSString*)openTagForType:(CommentStyleType)type;
+ (NSString*)closeTagForType:(CommentStyleType)type;

+ (CommentStyle*)styleWithType:(CommentStyleType)type start:(NSInteger)start end:(NSInteger)end text:(NSString*)text;

@end
