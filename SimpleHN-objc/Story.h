//
//  Story.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "User.h"

typedef NS_ENUM(NSInteger, StorySizeStatus) {
    StorySizeStatusNormal,
    StorySizeStatusExpanded
};

typedef NS_ENUM(NSInteger, StoryLoadStatus) {
    StoryLoadStatusNotLoaded,
    StoryLoadStatusLoading,
    StoryLoadStatusLoaded
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

@property (nonatomic, copy, readonly) NSNumber * totalCommentCount;

// Custom properties
@property (nonatomic, strong) NSNumber * ranking; // Position in top stories array

@property (nonatomic, strong) NSMutableArray * comments;
@property (nonatomic, strong) NSMutableArray * flatDisplayComments;

@property (nonatomic, strong) NSDictionary * diff;

@property (nonatomic, assign) StorySizeStatus sizeStatus;

// Generated properties
@property (nonatomic, strong, readonly) NSString * subtitleString;
@property (nonatomic, strong, readonly) NSString * timeString;

+ (void)createStoryFromItemIdentifier:(NSNumber*)identifier
                           completion:(StoryBlock)completion;

+ (void)createStoryFromSnapshot:(FDataSnapshot*)snapshot
                           completion:(StoryBlock)completion;

+ (Story*)createStoryFromAlgoliaResult:(NSDictionary*)result;

- (void)loadCommentsForStory;
- (void)loadUserForStory:(UserBlock)completion;

- (NSDictionary*)diffOtherStory:(Story*)otherStory;

@end
