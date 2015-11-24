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

@interface Comment ()
- (NSArray<CommentStyle*>*)createStylesWithType:(CommentStyleType)type;
- (NSArray<CommentStyle*>*)createBlockQuoteStyles;
- (NSArray<CommentLink*>*)createLinks;
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
        
        NSString * text = (NSString*)value;
        text = [[[[[text componentsSeparatedByString:@"<p>"] componentsJoinedByString:@"\n\n"] componentsSeparatedByString:@"</p>"] componentsJoinedByString:@"\n\n"] stringByDecodingHTMLEntities];
        
        return text;
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
- (NSArray<CommentLink*> *)links {
    if(_links) {
        return _links;
    }
    
    if(self.text == nil || [self.text length] == 0) {
        _links = @[];
        return _links;
    }
    
    _links = [self createLinks];
    return _links;
}

- (NSArray<CommentStyle*>*)styles {
    if(_styles) {
        return _styles;
    }
    
    NSArray * italicStyles = [self createStylesWithType:CommentStyleTypeItalic];
    
    NSMutableArray * stylesArray = [italicStyles mutableCopy];
    [stylesArray addObjectsFromArray:[self createStylesWithType:CommentStyleTypeBold]];
    [stylesArray addObjectsFromArray:[self createStylesWithType:CommentStyleTypeCode]];
    [stylesArray addObjectsFromArray:[self createBlockQuoteStyles]];
    
    _styles = [stylesArray copy];
    
    return _styles;
}

- (NSAttributedString*)attributedText {
    if(_attributedText) {
        return _attributedText;
    }
    
    if(self.text == nil || [self.text length] == 0) {
        return nil;
    }
    
    [self createLinks];
    
    NSMutableAttributedString * mutableAttributedText = [[NSMutableAttributedString alloc]
                                                         initWithString:self.text];
    [mutableAttributedText addAttribute:NSFontAttributeName value:
        [LabelHelper adjustedBodyFont] range:NSMakeRange(0, [_text length])];
    
    for(CommentStyle * style in self.styles) {
        
        UIFont * fontForType = nil;
        if(style.type == CommentStyleTypeItalic) {
            fontForType = [LabelHelper adjustedItalicBodyFont];
            
        } else if(style.type == CommentStyleTypeBold) {
            fontForType = [LabelHelper adjustedBoldBodyFont];
            
        } else if(style.type == CommentStyleTypeCode) {
            fontForType = [LabelHelper adjustedMonospacedBodyFont];
        }
        
        if(style.start < style.end) {
            if(style.type == CommentStyleTypeQuote) {
                [mutableAttributedText addAttribute:NSForegroundColorAttributeName value:
                 [UIColor grayColor] range:NSMakeRange(style.start, (style.end - style.start))];
                
            } else {
                
                @try {
                    [mutableAttributedText addAttribute:NSFontAttributeName value:
                     fontForType range:NSMakeRange(style.start, (style.end - style.start))];
                }
                @catch (NSException *exception) {
                    NSLog(@"ERROR: %@", exception);
                }
            }
        }
    }
    
    _attributedText = [mutableAttributedText copy];
    return _attributedText;
}

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
- (NSArray<CommentStyle*>*)createStylesWithType:(CommentStyleType)type {
    
    NSMutableArray * mutableStyles = [[NSMutableArray alloc] init];
    
    if(self.text == nil || ![self.text containsString:
                             [CommentStyle openTagForType: type]]) {
        return mutableStyles;
    }
    
    NSMutableString * mutableText = [[NSMutableString alloc] initWithString:self.text];
    NSLog(@"mutableText: %@", mutableText);
    
    while([mutableText rangeOfString: [CommentStyle openTagForType:
                                       type]].location != NSNotFound) {
     
        NSString * openTag = [CommentStyle openTagForType:type];
        NSString * closeTag = [CommentStyle closeTagForType:type];
        
        NSRange rangeOfOpenTag = [mutableText rangeOfString:openTag];
        NSRange rangeOfCloseTag = [mutableText rangeOfString:closeTag];
        
        NSUInteger containedLocation = rangeOfOpenTag.location + [openTag length];
        NSUInteger containedLength = rangeOfCloseTag.location - (rangeOfOpenTag.location + [openTag length]);
        NSRange containedRange = NSMakeRange(containedLocation, containedLength);
        
//        if(containedRange.location == NSNotFound) {
//            continue;
//        }
        
        NSLog(@"%@", NSStringFromRange(containedRange));
        
        NSString * containedString = [mutableText substringWithRange:containedRange];
        NSLog(@"containedString: %@", containedString);
        
        NSInteger stringStart = (NSInteger)rangeOfOpenTag.location;
        NSInteger stringEnd = (NSInteger)(rangeOfCloseTag.location - [openTag length]);
        
        [mutableText deleteCharactersInRange:rangeOfOpenTag];
        [mutableText deleteCharactersInRange:NSMakeRange(stringEnd, [closeTag length])];
        
        NSString * extractedStringForAdjustedLengths = [mutableText substringWithRange:
                                                        NSMakeRange(stringStart, stringEnd - stringStart)];
        
        NSLog(@"stringStart: %lu, stringEnd: %lu, extracted: %@", stringStart, stringEnd, extractedStringForAdjustedLengths);
        
        NSLog(@"mutableText: %@", mutableText);
        
        NSDictionary * styleDict = @{ kCommentStyleType: @(type),
                                      kCommentStyleText: extractedStringForAdjustedLengths,
                                      kCommentStyleStart: @(stringStart),
                                      kCommentStyleEnd: @(stringEnd) };

        CommentStyle * style = [[CommentStyle alloc] initWithDictionary:styleDict];
        [mutableStyles addObject:style];
    }
    _text = [mutableText copy];
    
    return mutableStyles;
}

- (NSArray<CommentLink*>*)createLinks {
    
    NSScanner* newScanner = [NSScanner scannerWithString:self.text];
    NSMutableArray * mutableLinks = [[NSMutableArray alloc] init];
    
    NSString * activeLinkText = nil;
    NSUInteger startScanLocation = NSUIntegerMax;
    NSUInteger endScanLocation = NSUIntegerMax;
    
    while (![newScanner isAtEnd]) {
        
        [newScanner scanUpToString:@"<a " intoString:nil];
        startScanLocation = [newScanner scanLocation];
        
        [newScanner scanString:@"<a " intoString:nil];
        
        [newScanner scanUpToString:@"</a>" intoString:&activeLinkText];
        endScanLocation = [newScanner scanLocation];
        
        if(activeLinkText && startScanLocation != NSUIntegerMax
           && endScanLocation != NSUIntegerMax) {
            
            // All this hoop jumping is done so we don't have to initialize
            // an xml parser for such a short block of html, because if you multiply
            // that by 100 links in a thread, that's a lot of wasted resources on a mobile device
            NSString * linkText = [NSString stringWithFormat:@"<a %@</a>", activeLinkText];
            NSString * linkLabel = [[activeLinkText componentsSeparatedByString:@">"] lastObject];
            
            NSString * linkUrl = [[[[[activeLinkText componentsSeparatedByString:@"href="] lastObject]
                                    componentsSeparatedByString:@" "] firstObject] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            NSDictionary * linkDict = @{ kCommentLinkText: linkText,
                                         kCommentLinkLabel: linkLabel,
                                         kCommentLinkStart: @(startScanLocation),
                                         kCommentLinkEnd: @(endScanLocation),
                                         kCommentLinkUrl: [NSURL URLWithString:linkUrl] };
            
            CommentLink  * link = [[CommentLink alloc] initWithDictionary:linkDict];
            [mutableLinks addObject:link];
            
            // Reset values
            activeLinkText = nil;
            startScanLocation = NSUIntegerMax;
            endScanLocation = NSUIntegerMax;
        }
    }
    
    if([self.text containsString:@"<p>"]) {
        _text = [[[[self.text componentsSeparatedByString:@"<p>"] componentsJoinedByString:@"\n\n"] componentsSeparatedByString:@"</p>"] componentsJoinedByString:@"\n\n"];
    }
    
    if([mutableLinks count] > 0) {
        
        NSMutableString * mutableText = [[NSMutableString alloc] initWithString:self.text];
        for(CommentLink * link in mutableLinks) {
            
            NSRange rangeOfString = [mutableText rangeOfString:link.text];
            
            if(rangeOfString.location != NSNotFound) {
                [mutableText deleteCharactersInRange:rangeOfString];
                [mutableText insertString:link.label atIndex:rangeOfString.location];
                
                link.start = rangeOfString.location;
                link.end = rangeOfString.location + [link.label length];
            }
        }
        _text = [mutableText copy];
    }
    
    return mutableLinks;
}

- (NSArray<CommentStyle*>*)createBlockQuoteStyles {
    
    NSMutableArray * mutableQuoteStyles = [[NSMutableArray alloc] init];
    
    if(self.text == nil || [self.text rangeOfRegex:
                             [CommentStyle openTagForType: CommentStyleTypeQuote]].location == NSNotFound) {
        return mutableQuoteStyles;
    }
    
    NSMutableString * mutableText = [[NSMutableString alloc] initWithString:self.text];
    
    while([mutableText rangeOfRegex: [CommentStyle openTagForType:
                                       CommentStyleTypeQuote]].location != NSNotFound) {
        
        NSString * openTag = [CommentStyle openTagForType:CommentStyleTypeQuote];
        
        NSRange rangeOfOpenTag = [mutableText rangeOfRegex:openTag];
        
        // The openTag regex is compound (has two parts, split by |)
        // Get the part of the regex that actually matched
        openTag = [mutableText stringByMatching:openTag];
        
        NSRange rangeOfCloseTag = NSMakeRange(NSNotFound, 0);
        
        NSLog(@"%@", NSStringFromRange(rangeOfOpenTag));
        
        NSString * substringToEnd = [mutableText substringFromIndex:rangeOfOpenTag.location];
        NSString * substringToEndWithoutOpenTag = [mutableText substringFromIndex:
                                                   rangeOfOpenTag.location + [openTag length]];
        
        NSLog(@"%@", substringToEnd);
        
        // First instance of \n terminates block quote
        NSRange rangeOfEndOfQuote = [substringToEndWithoutOpenTag rangeOfRegex:@"\n"];
        if(rangeOfEndOfQuote.location != NSNotFound) {
            NSLog(@"%@", NSStringFromRange(rangeOfOpenTag));
            
            NSInteger indexOfSubstring = [mutableText rangeOfString:
                                          substringToEndWithoutOpenTag].location;
            NSLog(@"%lu", indexOfSubstring);
            
            rangeOfCloseTag = NSMakeRange(rangeOfEndOfQuote.location + indexOfSubstring,
                                          rangeOfEndOfQuote.length);
            
        } else { // Not found, quote until end
            NSLog(@"Not found, quote until end");
            rangeOfCloseTag = NSMakeRange([mutableText length], 0);
        }
        
        NSUInteger containedLocation = rangeOfOpenTag.location + [openTag length];
        NSUInteger containedLength = rangeOfCloseTag.location - (rangeOfOpenTag.location + [openTag length]);
        NSRange containedRange = NSMakeRange(containedLocation, containedLength);
        
        NSString * containedString = [mutableText substringWithRange:containedRange];
        
        // Ensure the quote doesn't get identified and a CommentStyle
        // object doesn't get instantiated again
        [mutableText deleteCharactersInRange:rangeOfOpenTag];
        
        NSInteger stringStart = (NSInteger)rangeOfOpenTag.location;
        NSInteger stringEnd = (NSInteger)(rangeOfCloseTag.location - [openTag length]);
        
        [mutableQuoteStyles addObject:[CommentStyle styleWithType:CommentStyleTypeQuote
                                                            start:stringStart end:stringEnd text:containedString]];
    }
    
    _text = [mutableText copy];
    
    return mutableQuoteStyles;
}

@end
