//
//  Comment.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "Comment.h"
#import "CommentStyle.h"
#import "NSString+HTML.h"
#import "LabelHelper.h"
#import "RegexKitLite.h"
#import "TFHpple.h"

#import "NSAttributedString+HTML.h"
#import "DTCoreTextConstants.h"

static NSString * _commentCSS = nil;
static NSRegularExpression * _leadingTrailingRegex = nil;

@interface Comment ()

- (void)commentCollapsedChanged:(NSNotification*)notification;

@property (nonatomic, assign) NSInteger childCommentsChangedUntilComplete;

@end

@implementation Comment
@synthesize attributedText = _attributedText;
@synthesize nightAttributedText = _nightAttributedText;
@synthesize linksLookup = _linksLookup;
@synthesize childCommentCount = _childCommentCount;

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    if(!_leadingTrailingRegex) {
        NSError * error = nil;
        _leadingTrailingRegex = [NSRegularExpression regularExpressionWithPattern:
                                      @"^\n+|\n+$" options:NSRegularExpressionCaseInsensitive error:&error];
        if(error) {
            NSLog(@"ERROR: Could not initialize _leadingTrailingRegex: %@", error);
        }
    }
    
    self.childComments = [[NSMutableArray alloc] init];
    self.indentation = 0;
    
    _sizeStatus = CommentSizeStatusNormal;
    
    _collapseOrigin = NO;
    
    _voteStatus = StoryCommentUserVoteNoVote;
    
    _childCommentCount = -1;
    _childCommentsChangedUntilComplete = -1;
    
    _cachedCommentTextHeight = -1;
    _cachedCommentExpandedTextHeight = -1;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"commentId": @"id",
             @"author":    @"by",
             @"text":      @"text",
             @"parent":    @"parent",
             @"time":      @"time",
             @"kids":      @"kids",
             @"deleted":   @"deleted"
             };
}

+ (NSValueTransformer *)textJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSString * string = (NSString*)value;
        
        if([string containsString:@"Think of strings in JavaScript"]) {
            NSLog(@"target");
        }
        
        string = [[self class] completeParagraphTags:string];
        if([string containsString:@"<p></p>"]) {
            string = [string stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
        }
        string = [[self class] wrapQuotesInBlockQuoteTags:string];
        string = [[self class] wrapMultiQuotesInBlockQuoteTags:string];
        
        if([string containsString:@"<pre><code>"]) {

        }
        
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
    [[self class] createCommentFromItemIdentifier:identifier story:nil completion:completion];
}

+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier story:(Story*)story
                             completion:(CommentBlock)completion {
    
    // Get comment for identification number
    NSString * commentURL = [NSString stringWithFormat:
                             @"https://hacker-news.firebaseio.com/v0/item/%@", identifier];
    __block Firebase * commentDetailRef = [[Firebase alloc] initWithUrl:commentURL];
    
    [commentDetailRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        [[self class] createCommentFromSnapshot:snapshot story:story completion:completion];
        [commentDetailRef removeAllObservers];
    }];
}

// The 'from snapshot' method is when we've already loaded the data
+ (void)createCommentFromSnapshot:(FDataSnapshot*)snapshot
                       completion:(CommentBlock)completion {
    [[self class] createCommentFromSnapshot:snapshot story:nil completion:completion];
}

+ (void)createCommentFromSnapshot:(FDataSnapshot*)snapshot story:(Story*)story
                       completion:(CommentBlock)completion {
    
    NSError * error = nil;
    Comment * obj = [MTLJSONAdapter modelOfClass:Comment.class
                              fromJSONDictionary:snapshot.value error:&error];
    completion(obj);
    
    NSDictionary * userInfo = @{};
    if(story) {
        userInfo = @{ kCommentCreatedStoryIdentifier: story.storyId };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCommentCreated
                                                        object:obj userInfo:userInfo];
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

- (void)findStoryForComment:(StoryBlock)completion {
    
    if(self.parent) {
        // Create comment from parent
//        NSLog(@"findStoryForComment, loading %@", self.parent);
        
        NSString * itemURL = [NSString stringWithFormat:
                                 @"https://hacker-news.firebaseio.com/v0/item/%@", self.parent];
        __block Firebase * itemRef = [[Firebase alloc] initWithUrl:itemURL];
        [itemRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            
            HNItemHelperIdentificationResult result = [HNItemHelper identifyHNItemWithSnapshotDictionary:
                                                       snapshot.value];
            if(result == HNItemHelperIdentificationResultComment) {
                
                [[self class] createCommentFromSnapshot:snapshot completion:^(Comment *comment) {
                    [comment findStoryForComment:completion];
                }];
                
            } else if(result == HNItemHelperIdentificationResultStory) {
                [Story createStoryFromSnapshot:snapshot completion:completion];
                
            } else {
                completion(nil); return;
            }
            
            [itemRef removeAllObservers];
        }];
        
    } else {
        completion(nil);
    }
}

#pragma mark - Property Override Methods
- (void)setSizeStatus:(CommentSizeStatus)sizeStatus {
    _sizeStatus = sizeStatus;
    
    // Propagate collapse/normalize to child comments
    if(sizeStatus == CommentSizeStatusCollapsed || sizeStatus == CommentSizeStatusNormal) {
//        NSLog(@"postNotification kCommentCollapsedChanged for comment with id: %@", self.commentId);
        
        if(_collapseOrigin) {
            NSInteger countForCommentsToModify = self.childCommentCount + 1; // Include self = +1
            
            self.childCommentsChangedUntilComplete = countForCommentsToModify;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCollapsedChanged:)
                                                         name:kCommentCollapsedChanged object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:
            kCommentCollapsedChanged object:self];
        
        // Recursively set collapsed value
        for(Comment * comment in _childComments) {
            comment.sizeStatus = sizeStatus;
        }
    }
}

- (NSAttributedString*)attributedText {
    if(_attributedText) {
        return _attributedText;
    }
    
    _attributedText = [[self class] createAttributedStringFromHTMLString:self.text];
    
    return _attributedText;
}

- (NSAttributedString*)nightAttributedText {
    if(_nightAttributedText) {
        return _nightAttributedText;
    }
    
    _nightAttributedText = [[self class] createNightAttributedStringFromAttributedString:self.attributedText];
    
    return _nightAttributedText;
}

- (NSDictionary*)linksLookup {
    if(_linksLookup) {
        return _linksLookup;
    }
    
    _linksLookup = [[self class] extractLinksLookup:self.text];
    
    return _linksLookup;
}

- (NSString*)shareTitle {
    return [NSString stringWithFormat:@"Comment from %@", self.author];
}

- (NSURL*)hnPublicLink {
    return [NSURL URLWithString: [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@", self.commentId]];
}

- (BOOL)isEqual:(id)object {
    return ([object isKindOfClass:[Comment class]] &&
            [((Comment*)object).commentId isEqual:self.commentId]);
}

- (NSInteger)childCommentCount {
    
    if([self.childComments count] == 0) {
        return 0;
    }
    
    NSMutableArray *visitedNodes = [[NSMutableArray alloc] init];
    NSMutableArray *queue = [NSMutableArray arrayWithObject:self];
    
    while ([queue count] > 0) {
        Comment * c = [queue firstObject];
        [queue removeObject:c];
        
        if(![visitedNodes containsObject:c]) {
            [visitedNodes addObject:c];
            
            for(Comment *child in c.childComments) {
                [queue addObject:child];
            }
        }
    }

    // Should not include self?
    return [visitedNodes count] - 1;
}

- (void)commentCollapsedChanged:(NSNotification*)notification {
    
    if(self.childCommentsChangedUntilComplete != -1) {
        self.childCommentsChangedUntilComplete--;
//        NSLog(@"childCommentsChangedUntilComplete = %lu",
//              _childCommentsChangedUntilComplete);
        
        if(self.childCommentsChangedUntilComplete == 0) {
            
            NSLog(@"post kCommentCollapsedComplete");
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:
             kCommentCollapsedComplete object:self];
            
            _collapseOrigin = NO;
        }
    }
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

+ (NSString*)wrapMultiQuotesInBlockQuoteTags:(NSString*)string {
 
//    string = @"<p><pre><code>  &gt; Think MSIE. For a long time it was a horrible browser,&gt; but held its market-share simply by being the default. </code></pre> That&#x27;s not entirely true. IE since about ~4 was the best browser around (I choose to ignore IE5 for Mac). NN4 was horrible. The problem with IE was that it stagnated, so when Firefox came out it soon started to kick IEs ass and only then the &quot;default&quot; part became a problem.</p>";
    
    // Alternative case, has both quote and initial part of comment embedded in pre/code tag
    // Part of comment should not be discarded
//    string = @"<p><pre><code>  &gt; i particularly like the &quot;send tab to desktop browser&quot; feature</code></pre>Is this feature a discrete mechanism? Because I do this all the time, but by a different means: on desktop, I go Hamburger Menu &gt; History &gt; Tabs From Other Devices, which shows you a list of all your tabs from every synced device.</p>";
    
    if([string rangeOfRegex:[CommentStyle openTagForType:CommentStyleTypeMultiQuote]].location != NSNotFound) {
     
        NSMutableString * commentMutable = [[NSMutableString alloc] init];
        NSMutableArray * quotesToReplace = [[NSMutableArray alloc] init];
        
        TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray * elements = [doc searchWithXPathQuery:@"//html/body/*"];
        
        for(TFHppleElement * e in elements) {
            [commentMutable appendString:e.raw];
        }
        
        NSString * commentRaw = [commentMutable copy];
        NSArray * preElements = [doc searchWithXPathQuery:@"//pre/code"];
        
        for(TFHppleElement * e in preElements) {
            NSString * rawWithoutTags = [[e.raw stringByReplacingOccurrencesOfString:@"<code>" withString:@""]
                                         stringByReplacingOccurrencesOfString:@"</code>" withString:@""];
            
            NSMutableArray * quotes = [[NSMutableArray alloc] init];
            for(NSString * quote in [rawWithoutTags componentsSeparatedByString:@"&gt;"]) {
                
                NSString * trimmedString = [quote stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if([trimmedString length] > 0) {
                    [quotes addObject:trimmedString];
                }
            }
            
            NSString * multiString = [NSString stringWithFormat:@"<p><blockquote>%@</blockquote></p>",
                                      [quotes componentsJoinedByString:@"\n "]];
            
            // Get the entire paragraph for the multi-quote
            NSString * paragraphForMultiString = [NSString stringWithFormat:@"<pre>%@</pre>", e.raw];
            [quotesToReplace addObject:@[ paragraphForMultiString, multiString ]];
        }
        
        for(NSArray * quote in quotesToReplace) {
            // Also replace empty paragraph tags, which just increase size of textview needlessly
            commentRaw = [[commentRaw stringByReplacingOccurrencesOfString:
                           [quote firstObject] withString:[quote lastObject]]
                          stringByReplacingOccurrencesOfString:@"<p/>" withString:@""];
        }
        
        NSArray * preComponents = [string componentsSeparatedByString:@"</pre>"];
        if(![[preComponents lastObject] isEqualToString:@"</p>"]) {
            NSString * subsequentComment = [NSString stringWithFormat:@"<p>%@",
                                            [preComponents lastObject]];
            NSLog(@"%@", subsequentComment);
            commentRaw = [commentRaw stringByAppendingString:subsequentComment];
        }
        NSLog(@"%@", preComponents);
        
        string = commentRaw;
    }
    
    return string;
}

+ (NSAttributedString*)createNightAttributedStringFromAttributedString:(NSAttributedString *)string {
    NSMutableAttributedString * mutableAttributedString = [string mutableCopy];
    
    [mutableAttributedString enumerateAttributesInRange:NSMakeRange(0, [mutableAttributedString length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        
        if([[attrs allKeys] containsObject:NSForegroundColorAttributeName]) {
            UIColor * color = attrs[NSForegroundColorAttributeName];
            
            if([color isEqual:[UIColor blackColor]]) {
                [mutableAttributedString removeAttribute:NSForegroundColorAttributeName range:range];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
                
            } else {
                
                // This seems very specific, but we're trying to catch the default link color of DTCoreText
                const CGFloat *components = CGColorGetComponents(color.CGColor);
                NSNumber * blue = @([[NSString stringWithFormat:@"%.00f", components[2] * 10.0f] floatValue]);
                
                if([blue integerValue] == 9) {
                    [mutableAttributedString removeAttribute:NSForegroundColorAttributeName range:range];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
                }
            }
        }
    }];
    
    return [mutableAttributedString copy];
}

+ (NSAttributedString*)createAttributedStringFromHTMLString:(NSString*)string {
    
    if([string containsString:@"were going with blocking at the router"]) {
        NSLog(@"target");
    }
    
    NSMutableAttributedString *text = [[[NSAttributedString alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding] options:@{ DTUseiOS6Attributes: @YES } documentAttributes:nil] mutableCopy];
    
    // Fix stupid issue with DTCoreText turning <p><blockquote> into \n\n
    if(text) {
        NSMutableString * mutableText = [text mutableString];
        while([mutableText rangeOfString:@"\n\n"].location != NSNotFound) {
            NSRange rangeOfDoubleNewline = [mutableText rangeOfString:@"\n\n"];
            [mutableText deleteCharactersInRange:rangeOfDoubleNewline];
            [mutableText insertString:@"\n" atIndex:rangeOfDoubleNewline.location];
        }
        
        // Fix leading and trailing space issues
        @try {
            NSArray* matches = [_leadingTrailingRegex matchesInString:mutableText options:0
                                                range:NSMakeRange(0, [mutableText length])];
            matches = [[matches reverseObjectEnumerator] allObjects];
            
            for(NSTextCheckingResult * match in matches) {
                [mutableText deleteCharactersInRange:match.range];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"CRASH: when removing leading/trailing whitespace on comment");
        }
    }
    NSRange range = (NSRange){0, [text length]};
    
    [text enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont* currentFont = value;
        
        if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [text addAttribute:NSFontAttributeName
                                value:[LabelHelper adjustedBoldBodyFont] range:range];
            
        } else if ([currentFont.fontName rangeOfString:@"italic" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [text addAttribute:NSFontAttributeName
                                value:[LabelHelper adjustedItalicBodyFont] range:range];
        } else {
            [text addAttribute:NSFontAttributeName
                                value:[LabelHelper adjustedBodyFont] range:range];
        }
    }];
    
    [text enumerateAttributesInRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        
        // Detect links and remove any link metadata created by DTCoreText
        // As appreciated as it is, it screws with our label class, which is also
        // trying to detect links and does not function with pre-detected links
        if([[attrs allKeys] containsObject:NSLinkAttributeName]) {
            [text removeAttribute:NSLinkAttributeName range:range];
            [text removeAttribute:@"CTForegroundColorFromContext" range:range];
            [text removeAttribute:@"DTGUID" range:range];
            [text removeAttribute:@"DTLinkHighlightColor" range:range];
            [text removeAttribute:NSUnderlineStyleAttributeName range:range];
            [text removeAttribute:NSParagraphStyleAttributeName range:range];
        }
    }];
    
    return text;
}

+ (NSDictionary*)extractLinksLookup:(NSString*)string {

    if(![string containsString:@"<a "]) {
        return @{};
    }
    if(![string containsString:@"..."]) {
        return @{};
    }
    
    NSMutableDictionary * lookup = [[NSMutableDictionary alloc] init];
    
    TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray * elements = [doc searchWithXPathQuery:@"//a"];
    
    for(TFHppleElement * e in elements) {
        
        if([[e tagName] isEqualToString:@"a"] && [[[e attributes] allKeys] containsObject:@"href"]) {
            NSString * href = e.attributes[@"href"];
            NSString * content = [e.content stringByReplacingOccurrencesOfString:@"..." withString:@""];
            
            if(href && [href length] > 0 && content && [content length] > 0) {
                lookup[content] = href;
            }
        }
    }
    
    return lookup;
}

@end
