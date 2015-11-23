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

@interface Comment ()
- (NSArray<CommentStyle*>*)createStylesWithType:(CommentStyleType)type;
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
        return [((NSString*)value) stringByDecodingHTMLEntities];
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
    
    _text = [[[[self.text componentsSeparatedByString:@"<p>"] componentsJoinedByString:@"\n\n"] componentsSeparatedByString:@"</p>"] componentsJoinedByString:@"\n\n"];    

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
    
    _links = [mutableLinks copy];
    
    return _links;
}

- (NSArray<CommentStyle*>*)styles {
    if(_styles) {
        return _styles;
    }
    
    NSArray * italicStyles = [self createStylesWithType:CommentStyleTypeItalic];
    NSArray * boldStyles = [self createStylesWithType:CommentStyleTypeBold];
    
    NSMutableArray * stylesArray = [italicStyles mutableCopy];
    [stylesArray addObjectsFromArray:boldStyles];
    
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
    
    _text = [[[[self.text componentsSeparatedByString:@"<p>"] componentsJoinedByString:@"\n\n"] componentsSeparatedByString:@"</p>"] componentsJoinedByString:@"\n\n"];
    
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
        }
        if(style.start < style.end) {
            [mutableAttributedText addAttribute:NSFontAttributeName value:
             fontForType range:NSMakeRange(style.start, (style.end - style.start))];
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
    
    if(self.text == nil) {
        return @[];
    }
    
    NSMutableString * mutableText = [[NSMutableString alloc] initWithString:self.text];
    
    NSScanner* newScanner = [NSScanner scannerWithString:self.text];
    NSMutableArray * mutableStyles = [[NSMutableArray alloc] init];
    
    NSString * activeStyleText = nil;
    NSUInteger startScanLocation = NSUIntegerMax;
    NSUInteger endScanLocation = NSUIntegerMax;
    NSUInteger rangeOffset = 0;
    
    while (![newScanner isAtEnd]) {
        
        [newScanner scanUpToString:[CommentStyle openTagForType:type]
                        intoString:nil];
        startScanLocation = [newScanner scanLocation];
        
        [newScanner scanUpToString:[CommentStyle closeTagForType:type]
                        intoString:&activeStyleText];
        endScanLocation = [newScanner scanLocation];
        
        if(activeStyleText && startScanLocation != NSUIntegerMax
           && endScanLocation != NSUIntegerMax) {
            
            NSString * cleanText = [activeStyleText stringByReplacingOccurrencesOfString:
                               [CommentStyle openTagForType:type] withString:@""];
            
            activeStyleText = [NSString stringWithFormat:@"%@%@", activeStyleText,
                               [CommentStyle closeTagForType:type]];
            
            NSRange styleRange = NSMakeRange(startScanLocation - rangeOffset, [activeStyleText length]);
            NSLog(@"target string: %@", [mutableText substringWithRange:styleRange]);
            
            [mutableText deleteCharactersInRange:NSMakeRange(startScanLocation, [activeStyleText length])];
            [mutableText insertString:cleanText atIndex:startScanLocation];
            
            rangeOffset += ([[CommentStyle openTagForType:type] length] +
                            [[CommentStyle closeTagForType:type] length]);
            
            NSDictionary * styleDict = @{ kCommentStyleType: @(type),
                                         kCommentStyleText: activeStyleText,
                                         kCommentStyleStart: @(startScanLocation),
                                         kCommentStyleEnd: @(endScanLocation) };
            
            CommentStyle * style = [[CommentStyle alloc] initWithDictionary:styleDict];
            [mutableStyles addObject:style];
            
            // Reset values
            activeStyleText = nil;
            startScanLocation = NSUIntegerMax;
            endScanLocation = NSUIntegerMax;
        }
    }
    
    _text = [mutableText copy];
    
    return mutableStyles;
}

@end
