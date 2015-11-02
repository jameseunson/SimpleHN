//
//  CommentLink.h
//  SimpleHN-objc
//
//  Created by James Eunson on 2/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

// Parameters for dictionary initialization
#define kCommentLinkText @"commentLinkText"
#define kCommentLinkLabel @"commentLinkLabel"
#define kCommentLinkStart @"commentLinkStart"
#define kCommentLinkUrl @"commentLinkUrl"
#define kCommentLinkEnd @"commentLinkEnd"

@interface CommentLink : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * label;

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;

@property (nonatomic, strong) NSURL * url;

@end
