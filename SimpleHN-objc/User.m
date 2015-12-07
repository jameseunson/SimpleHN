//
//  User.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

//  id	The user's unique username. Case-sensitive. Required.
//  delay	Delay in minutes between a comment's creation and its visibility to other users.
//  created	Creation date of the user, in Unix Time.
//  karma	The user's karma.
//  about	The user's optional self-description. HTML.
//  submitted	List of the user's stories, polls and comments.

#import "User.h"
#import "NSString+HTML.h"
#import "Firebase.h"

#import "NSAttributedString+HTML.h"
#import "DTCoreTextConstants.h"

@implementation User
@synthesize accountCreatedString = _accountCreatedString;
@synthesize accountCreatedDate = _accountCreatedDate;
@synthesize submissionsString = _submissionsString;
@synthesize attributedAboutText = _attributedAboutText;

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"id",
             @"delay": @"delay",
             @"created": @"created",
             @"karma": @"karma",
             @"about": @"about",
             @"submitted": @"submitted"
             };
}

+ (NSValueTransformer *)aboutJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSString * string = ((NSString*)value);
        
        string = [Comment completeParagraphTags:string];
        if([string containsString:@"<p></p>"]) {
            string = [string stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
        }
        string = [Comment wrapQuotesInBlockQuoteTags:string];
        string = [Comment wrapMultiQuotesInBlockQuoteTags:string];
        
        return string;
    }];
}

+ (void)createUserFromItemIdentifier:(NSString*)identifier
                             completion:(UserBlock)completion {
    
    // Get comment for identification number
    NSString * userURL = [NSString stringWithFormat:
                             @"https://hacker-news.firebaseio.com/v0/user/%@", identifier];
    NSLog(@"%@", userURL);
    
    __block Firebase * userDetailRef = [[Firebase alloc] initWithUrl:userURL];
    [userDetailRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        NSError * error = nil;
        User * obj = [MTLJSONAdapter modelOfClass:User.class
                                  fromJSONDictionary:snapshot.value error:&error];
        completion(obj);
    }];
}

#pragma mark - Property Override Methods
- (NSAttributedString*)attributedAboutText {
    if(_attributedAboutText) {
        return _attributedAboutText;
    }
    
    _attributedAboutText = [Comment createAttributedStringFromHTMLString:self.about];
    
    return _attributedAboutText;
}

- (NSDate*)accountCreatedDate {
    if(_accountCreatedDate) {
        return _accountCreatedDate;
    }
    _accountCreatedDate = [NSDate dateWithTimeIntervalSince1970:
                           [self.created doubleValue]];
    
    return _accountCreatedDate;
}

- (NSString*)accountCreatedString {
    if(_accountCreatedString) {
        return _accountCreatedString;
    }
    
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date] toDate:self.accountCreatedDate options:0];
    int days = abs( [@(components.day) intValue] );
    
    _accountCreatedString = [NSString stringWithFormat:@"Account created %d days ago", days];
    
    return _accountCreatedString;
}

- (NSString*)submissionsString {
    if(_submissionsString) {
        return _submissionsString;
    }
    if([self.submitted count] == 1) {
        _submissionsString = [NSString stringWithFormat:@"%lu submission",
                [self.submitted count]];
        
    } else if([self.submitted count] > 1) {
        _submissionsString = [NSString stringWithFormat:@"%lu submissions",
                [self.submitted count]];
        
    } else { // 0
        _submissionsString = [NSString stringWithFormat:@"No submissions"];
    }
    
    return _submissionsString;
}

@end