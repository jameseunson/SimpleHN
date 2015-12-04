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
#import "CommentStyle.h"
#import "User.h"
#import "Firebase.h"

typedef NS_ENUM(NSInteger, CommentSizeStatus) {
    CommentSizeStatusNormal,
    CommentSizeStatusExpanded,
    CommentSizeStatusCollapsed
};

#define kCommentCreated @"commentCreated"
#define kCommentCollapsedChanged @"commentCollapsedChanged"
#define kCommentCollapsedComplete @"commentCollapsedComplete"

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
@property (nonatomic, strong) Comment * parentComment;

@property (nonatomic, assign) CommentSizeStatus sizeStatus;
@property (nonatomic, assign) BOOL collapseOrigin;

@property (nonatomic, assign) CGFloat cachedCommentExpandedTextHeight;
@property (nonatomic, assign) CGFloat cachedCommentTextHeight;

// Generated properties
@property (nonatomic, strong, readonly) NSArray <CommentLink *> * links;
@property (nonatomic, strong, readonly) NSArray <CommentStyle *> * styles;

@property (nonatomic, assign, readonly) NSInteger childCommentCount;

// text property with styles applied. Links are handled by KILabel
@property (nonatomic, strong, readonly) NSAttributedString * attributedText;

+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier
                            completion:(CommentBlock)completion;
+ (void)createCommentFromSnapshot:(FDataSnapshot*)snapshot
                             completion:(CommentBlock)completion;
- (void)loadUserForComment:(UserBlock)completion;
@end
