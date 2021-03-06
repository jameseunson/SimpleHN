//
//  Comment.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>
#import "User.h"
#import "Firebase.h"
#import "Story.h"
#import "StoryCommentUserVote.h"

typedef NS_ENUM(NSInteger, CommentSizeStatus) {
    CommentSizeStatusNormal = 0,
    CommentSizeStatusExpanded = 1,
    CommentSizeStatusCollapsed = 2,
    CommentSizeStatusCollapsedVisible = 3
};

#define kCommentCreated @"commentCreated"
#define kCommentCreatedComment @"commentCreatedComment"

// Represents transition from Normal -> Collapsed
#define kCommentCollapsedStarted @"commentCollapsedStarted"
#define kCommentCollapsedChanged @"commentCollapsedChanged"
#define kCommentCollapsedComplete @"commentCollapsedComplete"

// Represents transition from Collapsed -> Normal
#define kCommentExpandedStarted @"commentExpandedStarted"
#define kCommentExpandedChanged @"commentExpandedChanged"
#define kCommentExpandedComplete @"commentExpandedComplete"

// Key for userInfo dict sent back with kCommentCreated notification
#define kCommentCreatedStoryIdentifier @"commentCreatedStoryIdentifier"

// Key for userInfo dict sent back with kCommentCollapsedStarted, kCommentCollapsedChanged, kCommentCollapsedComplete
#define kCommentCollapsedExpandedStartedChangedCompleteComment @"commentCollapsedExpandedStartedChangedCompleteComment"

// Key for userInfo dict sent back with kCommentCollapsedChanged, used
// to filter out Expanded -> Normal as a collapse in receiver of notification
#define kCommentCollapsedExpandedPreviousState @"commentCollapsedExpandedPreviousState"

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
@property (nonatomic, assign, readonly) BOOL deleted;

// Custom properties
@property (nonatomic, strong) NSNumber * storyId;

@property (nonatomic, assign) NSInteger indentation;

@property (nonatomic, strong) NSMutableArray * childComments;
@property (nonatomic, strong) Comment * parentComment;

@property (nonatomic, assign) StoryCommentUserVote voteStatus;

@property (nonatomic, assign) CommentSizeStatus sizeStatus;
@property (nonatomic, assign) BOOL collapseExpandOrigin;
@property (nonatomic, strong) NSMutableDictionary* collapseExpandOriginIndexes;

@property (nonatomic, assign) CGFloat cachedCommentExpandedTextHeight;
@property (nonatomic, assign) CGFloat cachedCommentTextHeight;

// Generated properties
@property (nonatomic, assign, readonly) NSInteger childCommentCount;

@property (nonatomic, strong, readonly) NSString * shareTitle;
@property (nonatomic, strong, readonly) NSURL * hnPublicLink;

// text property with styles applied. Links are handled by TTTAttributedLabel
@property (nonatomic, strong, readonly) NSAttributedString * attributedText;
@property (nonatomic, strong, readonly) NSAttributedString * nightAttributedText;
@property (nonatomic, strong, readonly) NSDictionary * linksLookup;

+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier
                            completion:(CommentBlock)completion;
+ (void)createCommentFromItemIdentifier:(NSNumber*)identifier story:(Story*)story
                             completion:(CommentBlock)completion;

+ (void)createCommentFromSnapshot:(FDataSnapshot*)snapshot
                             completion:(CommentBlock)completion;
+ (void)createCommentFromSnapshot:(FDataSnapshot*)snapshot story:(Story*)story
                       completion:(CommentBlock)completion;

- (void)loadUserForComment:(UserBlock)completion;
- (void)findStoryForComment:(StoryBlock)completion;

// HTML processing utility methods, also being used in User model
+ (NSString*)completeParagraphTags:(NSString*)string;
+ (NSString*)wrapQuotesInBlockQuoteTags:(NSString*)string;
+ (NSString*)wrapMultiQuotesInBlockQuoteTags:(NSString*)string;

+ (NSDictionary*)extractLinksLookup:(NSString*)string;

+ (NSAttributedString*)createNightAttributedStringFromAttributedString:(NSAttributedString*)string;

+ (NSAttributedString*)createAttributedStringFromHTMLString:(NSString*)string;

+ (Comment*) currentCollapseExpandOrigin;
+ (void) setCurrentCollapseExpandOrigin:(Comment*)comment;

@end
