//
//  User.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Mantle/Mantle.h>

#define kUserCreated @"userCreated"

@class User;
typedef void (^UserBlock)(User* user);

@interface User : MTLModel <MTLJSONSerializing>

// Mantle properties
@property (nonatomic, copy, readonly) NSString * about;
@property (nonatomic, copy, readonly) NSNumber * created;
@property (nonatomic, copy, readonly) NSNumber * delay;

@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, copy, readonly) NSNumber * karma;

@property (nonatomic, copy, readonly) NSArray < NSNumber * > * submitted;

+ (void)createUserFromItemIdentifier:(NSString*)identifier
                          completion:(UserBlock)completion;

// Generated properties
@property (nonatomic, copy, readonly) NSDate * accountCreatedDate;
@property (nonatomic, copy, readonly) NSString * accountCreatedString;
@property (nonatomic, copy, readonly) NSString * submissionsString;

@property (nonatomic, strong, readonly) NSAttributedString * attributedAboutText;

@end
