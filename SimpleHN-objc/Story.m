//
//  Story.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "Story.h"
#import "NSString+HTML.h"
#import "Firebase.h"
#import "Comment.h"

@interface Story ()

- (void)commentCreated:(Comment*)comment;
- (void)commentCreatedAux:(Comment*)comment indentation:(NSInteger)indentation;

@end

@implementation Story

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    self.comments = [[NSMutableArray alloc] init];
    self.flatDisplayComments = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCreated:)
                                                 name:kCommentCreated object:nil];
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"storyId": @"id",
             @"author":  @"by",
             @"title":   @"title",
             @"url":     @"url",
             @"score":   @"score",
             @"time":    @"time",
             @"kids":    @"kids"
             };
}

+ (NSValueTransformer *)titleJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [((NSString*)value) stringByDecodingHTMLEntities];
    }];
}

+ (NSValueTransformer *)timeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:[value integerValue]];
    }];
}
+ (NSValueTransformer *)urlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (void)loadCommentsForStory {
    
    NSString * storyURL = [NSString stringWithFormat:
                           @"https://hacker-news.firebaseio.com/v0/item/%@/kids",
                           self.storyId];
    __block Firebase * commentsRef = [[Firebase alloc] initWithUrl:storyURL];
    
    [commentsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        for(FDataSnapshot * child in snapshot.children) {
            
            [Comment createCommentFromItemIdentifier:child.value completion:^(Comment *comment) {
                [self.comments addObject:comment];
            }];
        }
    }];
}

- (void)commentCreated:(Comment*)comment {
    
    // Create flat representation of comments
    [_flatDisplayComments removeAllObjects];
    
    for(Comment * comment in _comments) {
        [_flatDisplayComments addObject:comment];
        [self commentCreatedAux:comment indentation:1];
    }
}

- (void)commentCreatedAux:(Comment*)comment indentation:(NSInteger)indentation {
    
    // Base case
    if(!comment || ![comment childComments]
       || [[comment childComments] count] == 0) {
        return;
    }
    
    for(Comment * childComment in [comment childComments]) {
        childComment.indentation = indentation;
        
        [_flatDisplayComments addObject:childComment];
        [self commentCreatedAux:childComment indentation:(indentation + 1)];
    }
}

+ (void)createStoryFromItemIdentifier:(NSNumber*)identifier
                             completion:(StoryBlock)completion {
    // Get comment for identification number
    NSString * storyURL = [NSString stringWithFormat:
                             @"https://hacker-news.firebaseio.com/v0/item/%@", identifier];
    __block Firebase * storyDetailRef = [[Firebase alloc] initWithUrl:storyURL];
    [storyDetailRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        NSError * error = nil;
        Story * obj = [MTLJSONAdapter modelOfClass:Story.class
                                  fromJSONDictionary:snapshot.value error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(obj);
        });
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kStoryCreated
                                                            object:obj];
    }];
}

@end
