//
//  Comment.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "Comment.h"
#import "NSString+HTML.h"
#import "Firebase.h"
#import "FirebaseUI.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    self.childComments = [[NSMutableArray alloc] init];
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"commentId": @"id",
             @"author":    @"by",
             @"text":      @"text",
             @"parent":    @"parent",
             @"time":      @"time",
             @"kids":      @"kids"
             };
}

+ (NSValueTransformer *)textJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [((NSString*)value) stringByDecodingHTMLEntities];
    }];
}

+ (NSValueTransformer *)timeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:[value integerValue]];
    }];
}

+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier
                             completion:(CommentBlock)completion {
    
    NSLog(@"createCommentFromItemIdentifier: %@", identifier);
    
    // Get comment for identification number
    NSString * commentURL = [NSString stringWithFormat:
                             @"https://hacker-news.firebaseio.com/v0/item/%@", identifier];
    __block Firebase * commentDetailRef = [[Firebase alloc] initWithUrl:commentURL];
    [commentDetailRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        NSError * error = nil;
        Comment * obj = [MTLJSONAdapter modelOfClass:Comment.class
                                  fromJSONDictionary:snapshot.value error:&error];
        completion(obj);
        
        NSLog(@"commentDetailRef obj: %@", obj);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCommentCreated
                                                            object:obj];
        
        // load child comments into comment
        for(NSNumber * child in obj.kids) {
            
            __block Comment * blockObj = obj;
            [Comment createCommentFromItemIdentifier:child completion:^(Comment *comment) {
                [blockObj.childComments addObject:comment];
            }];
        }
    }];
}

@end
