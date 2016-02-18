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
#import "TimeAgoInWords-Swift.h"

static NSDateFormatter * _timeDateFormatter = nil;

@interface Story ()

+ (NSDateFormatter*)timeDateFormatter;

- (void)commentCreated:(NSNotification*)notification;
- (void)commentCreatedAux:(Comment*)comment indentation:(NSInteger)indentation;

@end

@implementation Story
@synthesize subtitleString = _subtitleString;
@synthesize timeString = _timeString;

@synthesize attributedText = _attributedText;
@synthesize nightAttributedText = _nightAttributedText;

@synthesize flatVisibleDisplayComments = _flatVisibleDisplayComments;

@synthesize linksLookup = _linksLookup;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    self.comments = [[NSMutableArray alloc] init];
    self.flatDisplayComments = [[NSMutableArray alloc] init];
    
    _algoliaResult = NO;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"storyId":           @"id",
             @"author":            @"by",
             @"title":             @"title",
             @"url":               @"url",
             @"score":             @"score",
             @"time":              @"time",
             @"text":              @"text",
             @"kids":              @"kids",
             @"totalCommentCount": @"descendants"
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

+ (NSValueTransformer *)textJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSString * string = ((NSString*)value);
        
        string = [Comment completeParagraphTags:string];
        if([string containsString:@"<p></p>"]) {
            string = [string stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
        }
        string = [Comment wrapQuotesInBlockQuoteTags:string];
        string = [Comment wrapMultiQuotesInBlockQuoteTags:string];
        
        return string;
    }];
}

- (void)loadCommentsForStory {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCreated:)
                                                 name:kCommentCreated object:nil];
    
    if([self.flatDisplayComments count] > 0) {
        [self.flatDisplayComments removeAllObjects];
    }
    if([self.comments count] > 0) {
        [self.comments removeAllObjects];
    }
    
    NSLog(@"Story, -loadCommentsForStory");
    
    NSString * storyURL = [NSString stringWithFormat:
                           @"https://hacker-news.firebaseio.com/v0/item/%@/kids",
                           self.storyId];
    
    __block Firebase * commentsRef = [[Firebase alloc] initWithUrl:storyURL];
    __block Story * blockSelf = self;
    
    [commentsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        for(FDataSnapshot * child in snapshot.children) {
            
            [Comment createCommentFromItemIdentifier:child.value story:self completion:^(Comment *comment) {
                [blockSelf.comments addObject:comment];
            }];
        }
    }];
}

- (void)loadSpecificCommentForStory:(NSNumber*)identifier {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCreated:)
                                                 name:kCommentCreated object:nil];
    
    if([self.flatDisplayComments count] > 0) {
        [self.flatDisplayComments removeAllObjects];
    }
    if([self.comments count] > 0) {
        [self.comments removeAllObjects];
    }
    NSLog(@"Story, -loadSpecificCommentForStory");
    
    NSString * commentURL = [NSString stringWithFormat:
                           @"https://hacker-news.firebaseio.com/v0/item/%@", identifier];
    
    __block Firebase * commentsRef = [[Firebase alloc] initWithUrl:commentURL];
    __block Story * blockSelf = self;
    
    [commentsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [Comment createCommentFromSnapshot:snapshot completion:^(Comment *comment) {
            [blockSelf.comments addObject:comment];
        }];
    }];
}

- (void)finishLoadingCommentsForStory {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadUserForStory:(UserBlock)completion {
    [User createUserFromItemIdentifier:self.author completion:completion];
}

- (void)commentCreated:(NSNotification*)notification {
    
    if(notification.userInfo) {
        NSDictionary * userInfo = notification.userInfo;
        if([[userInfo allKeys] containsObject:kCommentCreatedStoryIdentifier]) {
            if(![self.storyId isEqual:userInfo[kCommentCreatedStoryIdentifier]]) {
                NSLog(@"ERROR: comment was NOT intended for this story.");
                return;
            }
        }
    }
    
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
    
//    NSLog(@"createStoryFromItemIdentifier: %@", identifier);
    // Get comment for identification number
    NSString * storyURL = [NSString stringWithFormat:
                             @"https://hacker-news.firebaseio.com/v0/item/%@", identifier];
    __block Firebase * storyDetailRef = [[Firebase alloc] initWithUrl:storyURL];
    
    [storyDetailRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"createStoryFromItemIdentifier, RESULT: %@", identifier);        
        
        [[self class] createStoryFromSnapshot:snapshot completion:completion];
        [storyDetailRef removeAllObservers];
    }];
}

// Used internally and from UserViewController
+ (void)createStoryFromSnapshot:(FDataSnapshot*)snapshot
                     completion:(StoryBlock)completion {
    
    NSError * error = nil;
    
    if([snapshot.value isKindOfClass:[NSNull class]]) {
        completion(nil); return;
    }
    
    Story * obj = [MTLJSONAdapter modelOfClass:Story.class
                            fromJSONDictionary:snapshot.value error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(obj);
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kStoryCreated
                                                        object:obj];
}

+ (Story*)createStoryFromAlgoliaResult:(NSDictionary*)result {
    
    NSMutableDictionary * mutableStoryDict = [[NSMutableDictionary alloc] init];
    if([[result allKeys] containsObject:@"title"]) {
        mutableStoryDict[@"title"] = result[@"title"];
    }
    if([[result allKeys] containsObject:@"url"]) {
        mutableStoryDict[@"url"] = result[@"url"];
    }
    if([[result allKeys] containsObject:@"author"]) {
        mutableStoryDict[@"by"] = result[@"author"];
    }
    if([[result allKeys] containsObject:@"points"]) {
        if([result[@"points"] isKindOfClass:[NSNull class]]) {
            mutableStoryDict[@"score"] = @(0);
        } else {
            mutableStoryDict[@"score"] = @([result[@"points"] intValue]);
        }
    }
    if([[result allKeys] containsObject:@"num_comments"]) {
        if([result[@"num_comments"] isKindOfClass:[NSNull class]]) {
            mutableStoryDict[@"descendants"] = @(0);
        } else {
            mutableStoryDict[@"descendants"] = @([result[@"num_comments"] intValue]);
        }
    }
    if([[result allKeys] containsObject:@"objectID"]) {
        mutableStoryDict[@"id"] = @([result[@"objectID"] intValue]);
    }
    if([[result allKeys] containsObject:@"created_at_i"]) {
        mutableStoryDict[@"time"] = @([result[@"created_at_i"] intValue]);
    }
    if([[result allKeys] containsObject:@"story_text"]) {
        mutableStoryDict[@"text"] = result[@"text"];
    }
    
    // Strip whitespace from inputs, otherwise they can cause a Mantle crash, especially URLs
    for(NSString * key in [mutableStoryDict allKeys]) {
        if([mutableStoryDict[key] isKindOfClass:[NSString class]]) {
            mutableStoryDict[key] = [mutableStoryDict[key] stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    NSError * error = nil;
    Story * obj = [MTLJSONAdapter modelOfClass:Story.class
                            fromJSONDictionary:mutableStoryDict error:&error];
    if(error) {
        NSLog(@"createStoryFromAlgoliaResult, ERROR: %@", error);
    }
    
    return obj;
}

#pragma mark - Property Override Methods
- (NSString*)subtitleString {
    if(_subtitleString) {
        return _subtitleString;
    }
    
    if(self.url) {
        _subtitleString = [NSString stringWithFormat:@"%@ · %@ · %@",
                                        self.url.host, self.author, [self.time timeAgoInWords]];
    } else {
        _subtitleString = [NSString stringWithFormat:@"%@ · %@",
                                        self.author, [self.time timeAgoInWords]];
    }
    
    return _subtitleString;
}

- (NSString*)timeString {
    
    if(_timeString) {
        return _timeString;
    }
    
    _timeString = @"";
    if(self.time) {
        NSString * timeDateString = [[[self class] timeDateFormatter] stringFromDate:self.time];
        _timeString = [NSString stringWithFormat:@"%@ (%@)",
                      timeDateString, [self.time timeAgoInWords]];
    }
    return _timeString;
}

- (NSAttributedString*)attributedText {
    if(_attributedText) {
        return _attributedText;
    }
    
    _attributedText = [Comment createAttributedStringFromHTMLString:self.text];
    
    return _attributedText;
}

- (NSAttributedString*)nightAttributedText {
    if(_nightAttributedText) {
        return _nightAttributedText;
    }
    
    _nightAttributedText = [Comment createNightAttributedStringFromAttributedString:self.attributedText];
    
    return _nightAttributedText;
}

- (NSDictionary*)linksLookup {
    if(_linksLookup) {
        return _linksLookup;
    }
    
    _linksLookup = [Comment extractLinksLookup:self.text];
    
    return _linksLookup;
}


- (NSURL*)hnPublicLink {
    return [NSURL URLWithString: [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@", self.storyId]];
}

- (NSArray*)flatVisibleDisplayComments {
    
    NSArray * visibleDisplayComments = [self.flatDisplayComments filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        Comment * comment = (Comment*)evaluatedObject;
        if(comment.deleted || comment.parentComment.sizeStatus == CommentSizeStatusCollapsed) {
            return NO;
        }
        return YES;
    }]];
    return visibleDisplayComments;
}

+ (NSDateFormatter*)timeDateFormatter {
    if(!_timeDateFormatter) {
        _timeDateFormatter = [[NSDateFormatter alloc] init];
        _timeDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        _timeDateFormatter.dateFormat = @"hh:mm aaa, dd MMM";
    }
    return _timeDateFormatter;
}

@end
