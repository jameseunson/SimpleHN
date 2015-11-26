//
//  Comment.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "Comment.h"
#import "NSString+HTML.h"
#import "LabelHelper.h"
#import "RegexKitLite.h"
#import "TFHpple.h"

static NSString * _commentCSS = nil;

@interface Comment ()
+ (NSString*)completeParagraphTags:(NSString*)string;
+ (NSString*)wrapQuotesInBlockQuoteTags:(NSString*)string;
//+ (NSString*)commentCSS;

@end

@implementation Comment
@synthesize links = _links;
@synthesize styles = _styles;
@synthesize attributedText = _attributedText;

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    self.childComments = [[NSMutableArray alloc] init];
    self.indentation = 0;
    
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
        
        NSString * string = (NSString*)value;
        
//        NSMutableString * mutableText = [[NSMutableString alloc] initWithString:string];
//        [mutableText insertString:[[self class] commentCSS] atIndex:0];
//        string = [mutableText copy];
        
        string = [[self class] completeParagraphTags:string];
        if([string containsString:@"<p></p>"]) {
            string = [string stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
        }
        string = [[self class] wrapQuotesInBlockQuoteTags:string];
        
        return [string copy];
    }];
}

+ (NSValueTransformer *)timeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:[value integerValue]];
    }];
}

// The 'from identifier' method is when we have the identification
// number of the comment item, but the data must be loaded
+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier
                             completion:(CommentBlock)completion {
    
    // Get comment for identification number
    NSString * commentURL = [NSString stringWithFormat:
                             @"https://hacker-news.firebaseio.com/v0/item/%@", identifier];
    __block Firebase * commentDetailRef = [[Firebase alloc] initWithUrl:commentURL];
    
    [commentDetailRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        [[self class] createCommentFromSnapshot:snapshot completion:completion];
        [commentDetailRef removeAllObservers];
    }];
}

// The 'from snapshot' method is when we've already loaded the data
+ (void)createCommentFromSnapshot:(FDataSnapshot*)snapshot
                       completion:(CommentBlock)completion {
    
    NSError * error = nil;
    Comment * obj = [MTLJSONAdapter modelOfClass:Comment.class
                              fromJSONDictionary:snapshot.value error:&error];
    completion(obj);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCommentCreated
                                                        object:obj];
    // load child comments into comment
    for(NSNumber * child in obj.kids) {
        
        __block Comment * blockObj = obj;
        [Comment createCommentFromItemIdentifier:child completion:^(Comment *comment) {
            comment.parentComment = blockObj;
            [blockObj.childComments addObject:comment];
        }];
    }
}

- (void)loadUserForComment:(UserBlock)completion {
    [User createUserFromItemIdentifier:self.author completion:completion];
}

#pragma mark - Property Override Methods
- (void)setCollapsed:(BOOL)collapsed {
    _collapsed = collapsed;
    
    NSLog(@"postNotification kCommentCollapsedChanged for comment with id: %@", self.commentId);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:
     kCommentCollapsedChanged object:self];
    
    // Recursively set collapsed value
    for(Comment * comment in _childComments) {
        comment.collapsed = collapsed;
    }
}

- (BOOL)isEqual:(id)object {
    return ([object isKindOfClass:[Comment class]] &&
            [((Comment*)object).commentId isEqual:self.commentId]);
}

#pragma mark - Private Methods
+ (NSString*)completeParagraphTags:(NSString*)string {
    
    if([string containsString:@"<p>"]) {
        
        NSString * scannerBufferString = nil;
        
        NSMutableString * mutableString = [[NSMutableString alloc] initWithString:string];
//        NSRange closeStyleTagRange = [mutableString rangeOfString:@"</style>"];
//        NSInteger paragraphStartIndex = closeStyleTagRange.location + closeStyleTagRange.length;
        
//        [mutableString insertString:@"<p>" atIndex:paragraphStartIndex];
        [mutableString insertString:@"<p>" atIndex:0];
        
        NSMutableArray * locationsToAddCloseTags = [@[] mutableCopy];
        
        NSScanner * scanner = [NSScanner scannerWithString:mutableString];
//        scanner.scanLocation = paragraphStartIndex + [@"<p>" length];
        scanner.scanLocation = [@"<p>" length];
        
        while([[mutableString substringFromIndex:scanner.scanLocation] containsString:@"<p>"]) {
            [scanner scanUpToString:@"<p>" intoString:&scannerBufferString];
            
            [locationsToAddCloseTags addObject:@(scanner.scanLocation)];
            scanner.scanLocation = scanner.scanLocation + [@"<p>" length];
        }
        [locationsToAddCloseTags addObject:@(mutableString.length)];
        
        NSString * closeTag = @"</p>";
        int tagsAdded = 0;
        for(NSNumber * location in locationsToAddCloseTags) {
            [mutableString insertString:closeTag atIndex:[location intValue] +
                (tagsAdded * [closeTag length])];
            tagsAdded++;
        }
        return [mutableString copy];
        
    } else {
         return string;
    }
}

+ (NSString*)wrapQuotesInBlockQuoteTags:(NSString *)string {
    
    string = @"<p><pre><code>  &gt; Think MSIE. For a long time it was a horrible browser,&gt; but held its market-share simply by being the default. </code></pre> That&#x27;s not entirely true. IE since about ~4 was the best browser around (I choose to ignore IE5 for Mac). NN4 was horrible. The problem with IE was that it stagnated, so when Firefox came out it soon started to kick IEs ass and only then the &quot;default&quot; part became a problem.</p>";
    
    if([string rangeOfRegex:[CommentStyle openTagForType:CommentStyleTypeQuote]].location != NSNotFound) {
        
        NSMutableString * commentMutable = [[NSMutableString alloc] init];
        NSMutableArray * quotesToReplace = [[NSMutableArray alloc] init];
        
        TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray * elements = [doc searchWithXPathQuery:@"//html/body/*"];
        
        for(TFHppleElement * e in elements) {
            [commentMutable appendString:e.raw];
        }
        
        NSArray * pElements = [doc searchWithXPathQuery:@"//p"];
        for(TFHppleElement * e in pElements) {
            if([e.raw rangeOfRegex:[CommentStyle openTagForType:CommentStyleTypeQuote]].location != NSNotFound) {
                [quotesToReplace addObject:e.raw];
            }
        }
        
        NSString * commentRaw = [commentMutable copy];
        if([string rangeOfRegex:@"<p><pre><code>[ ]+&gt;"].location != NSNotFound) {
            
            NSArray * preElements = [doc searchWithXPathQuery:@"//pre/code"];
            for(TFHppleElement * e in preElements) {
                NSLog(@"%@", e);
                
                NSString * rawWithoutTags = [[e.raw stringByReplacingOccurrencesOfString:@"<code>" withString:@""] stringByReplacingOccurrencesOfString:@"</code>" withString:@""];
                
                NSArray * quotes = [[rawWithoutTags componentsSeparatedByString:@"&gt;"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [[((NSString*)evaluatedObject) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
                }]];
                NSLog(@"%@", quotes);
            }
        }
        
        for(NSString * quote in quotesToReplace) {
            
            NSString * modifiedQuote = [quote stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
            modifiedQuote = [modifiedQuote stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
            
            modifiedQuote = [[modifiedQuote stringByReplacingOccurrencesOfString:[modifiedQuote stringByMatching:[CommentStyle openTagForType:CommentStyleTypeQuote]] withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            //                modifiedQuote = [[modifiedQuote stringByReplacingOccurrencesOfString:@"&gt;" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            modifiedQuote = [NSString stringWithFormat:@"<p><blockquote>%@</blockquote></p>", modifiedQuote];
            
            commentRaw = [commentRaw stringByReplacingOccurrencesOfString:quote withString:modifiedQuote];
        }
        commentRaw = [NSString stringWithFormat:@"%@%@",
                      @"<style>blockquote{ color: #999999; margin: 0; padding: 0; } p {margin-bottom: 10px;}</style>", commentRaw];
        return commentRaw;
    }
    return string;
}

//+ (NSString*)commentCSS {
//    if(_commentCSS) {
//        return _commentCSS;
//    }
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"reset" ofType:@"css"];
//    NSURL * url = [NSURL fileURLWithPath:path];
//    
//    NSError * fileError = nil;
//    NSString * cssReset = [NSString stringWithContentsOfURL:url
//                                                   encoding:NSUTF8StringEncoding error:&fileError];
//    
//    _commentCSS = [NSString stringWithFormat:@"<style>%@ blockquote{ color: #999999; } p {margin-bottom: 20px;}</style>",
//                      cssReset];
//    return _commentCSS;
//}

@end
