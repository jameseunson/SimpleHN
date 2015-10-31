//
//  Comment.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>

#define kCommentCreated @"commentCreated"

@class Comment;
typedef void (^CommentBlock)(Comment* comment);

@interface Comment : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber * commentId;
@property (nonatomic, copy, readonly) NSString * author;
@property (nonatomic, copy, readonly) NSArray * kids;

@property (nonatomic, copy, readonly) NSNumber * parent;
@property (nonatomic, copy, readonly) NSDate * time;

@property (nonatomic, copy, readonly) NSString * text;

@property (nonatomic, strong) NSMutableArray * childComments;

+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier
                            completion:(CommentBlock)completion;
@end
