//
//  Comment.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>
#import "CommentLink.h"
#import "User.h"

#define kCommentCreated @"commentCreated"
#define kCommentCollapsedChanged @"commentCollapsedChanged"

@class Comment;
typedef void (^CommentBlock)(Comment* comment);

@interface Comment : MTLModel <MTLJSONSerializing>

// Mantle properties
@property (nonatomic, copy, readonly) NSNumber * commentId;
@property (nonatomic, copy, readonly) NSString * author;
@property (nonatomic, copy, readonly) NSArray * kids;

@property (nonatomic, copy, readonly) NSNumber * parent;
@property (nonatomic, copy, readonly) NSDate * time;

@property (nonatomic, copy, readonly) NSString * text;

// Custom properties
@property (nonatomic, assign) NSInteger indentation;
@property (nonatomic, strong) NSMutableArray * childComments;

@property (nonatomic, assign) BOOL collapsed;

// Generated properties
@property (nonatomic, strong) NSArray <CommentLink *> * links;

+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier
                            completion:(CommentBlock)completion;
- (void)loadUserForComment:(UserBlock)completion;
@end
