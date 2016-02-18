//
//  Story.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "User.h"
#import "StoryCommentUserVote.h"

typedef NS_ENUM(NSInteger, StorySizeStatus) {
    StorySizeStatusNormal = 0,
    StorySizeStatusExpanded = 1
};

typedef NS_ENUM(NSInteger, StoryLoadStatus) {
    StoryLoadStatusNotLoaded,
    StoryLoadStatusLoading,
    StoryLoadStatusLoaded
};

typedef NS_ENUM(NSInteger, StoryType) {
    StoryTypeDefault,
    StoryTypeAskHN
};

@class Story;
typedef void (^StoryBlock)(Story* story);

#define kStoryCreated @"storyCreated"

@interface Story : MTLModel <MTLJSONSerializing>

// Mantle properties
@property (nonatomic, copy, readonly) NSNumber * storyId;
@property (nonatomic, copy, readonly) NSString * author;
@property (nonatomic, copy, readonly) NSArray * kids;

@property (nonatomic, copy, readonly) NSNumber * score;
@property (nonatomic, copy, readonly) NSDate * time;

@property (nonatomic, copy, readonly) NSString * title;
@property (nonatomic, copy, readonly) NSURL * url;

@property (nonatomic, copy, readonly) NSString * text;

@property (nonatomic, copy, readonly) NSNumber * totalCommentCount;

// Custom properties
@property (nonatomic, strong) NSNumber * ranking; // Position in top stories array

@property (nonatomic, strong) NSMutableArray * comments;
@property (nonatomic, strong) NSMutableArray * flatDisplayComments;
@property (nonatomic, strong, readonly) NSArray * flatVisibleDisplayComments; // No collapsed

@property (nonatomic, assign) StoryCommentUserVote voteStatus;

@property (nonatomic, assign) StorySizeStatus sizeStatus;

@property (nonatomic, assign) BOOL algoliaResult; // Items from Algolia are missing a lot of information, so must be reloaded

// Generated properties
@property (nonatomic, strong, readonly) NSString * subtitleString;
@property (nonatomic, strong, readonly) NSString * timeString;

@property (nonatomic, strong, readonly) NSAttributedString * attributedText;
@property (nonatomic, strong, readonly) NSAttributedString * nightAttributedText;

@property (nonatomic, strong, readonly) NSDictionary * linksLookup;

@property (nonatomic, strong, readonly) NSURL * hnPublicLink;

+ (void)createStoryFromItemIdentifier:(NSNumber*)identifier
                           completion:(StoryBlock)completion;

+ (void)createStoryFromSnapshot:(FDataSnapshot*)snapshot
                           completion:(StoryBlock)completion;

+ (Story*)createStoryFromAlgoliaResult:(NSDictionary*)result;

- (void)loadCommentsForStory;
- (void)loadSpecificCommentForStory:(NSNumber*)identifier;

- (void)finishLoadingCommentsForStory;

- (void)loadUserForStory:(UserBlock)completion;

@end
