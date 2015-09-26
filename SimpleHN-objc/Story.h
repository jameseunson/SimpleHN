//
//  Story.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Story : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber * storyId;
@property (nonatomic, copy, readonly) NSString * author;
@property (nonatomic, copy, readonly) NSArray * kids;

@property (nonatomic, copy, readonly) NSNumber * score;
@property (nonatomic, copy, readonly) NSDate * time;

@property (nonatomic, copy, readonly) NSString * title;
@property (nonatomic, copy, readonly) NSURL * url;

@end
