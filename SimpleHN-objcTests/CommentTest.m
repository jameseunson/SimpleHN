//
//  CommentTest.m
//  SimpleHN-objc
//
//  Created by James Eunson on 24/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BaseTest.h"
#import "Comment.h"
#import "Mantle.h"

@interface CommentTest : BaseTest
- (Comment*)createCommentFromInputFileWithName:(NSString*)filename;
@end

@implementation CommentTest

- (void)testInput1 {
    
    Comment * comment = [self createCommentFromInputFileWithName:
                         @"CommentTest-input-1.html"];
    
    // This particular example has two expected styles
    XCTAssert([comment.styles count] == 2, @"Two expected styles, found %lu",
              [comment.styles count]);
}

- (void)testInput2 {

    Comment * comment = [self createCommentFromInputFileWithName:
                         @"CommentTest-input-2.html"];
    
    NSArray * quoteStyles = [comment.styles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                                         @"type == %d", CommentStyleTypeQuote]];

    // This particular example has one expected block style
    XCTAssert([quoteStyles count] == 1, @"One expected quote style, found %lu",
              [quoteStyles count]);
    
    CommentStyle * firstStyle = [quoteStyles firstObject];
    NSString * expectedText = @" …it is worth avoiding the dilution of development efforts on something that is neither the developer’s core competence or the target application.";
    
    XCTAssert([firstStyle.text isEqualToString:expectedText], @"Expected: %@, found: %@",
              expectedText, firstStyle.text);
}

- (void)testInput3 {
    
    Comment * comment = [self createCommentFromInputFileWithName:
                         @"CommentTest-input-3.html"];
    
    NSArray * quoteStyles = [comment.styles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                                         @"type == %d", CommentStyleTypeQuote]];
    
    // This particular example has two expected block styles
    XCTAssert([quoteStyles count] == 2, @"Two expected quote styles, found %lu",
              [quoteStyles count]);
    
    CommentStyle * firstStyle = [quoteStyles firstObject];
    NSString * expectedText = @"So Automattic, maker of the largest open source PHP CMS in the world has thrown out PHP in favor of node.js for their own site.";
    
    // Ensure that the complete quote was extracted without clipping
    XCTAssert([firstStyle.text isEqualToString:expectedText], @"Expected: %@, found: %@",
              expectedText, firstStyle.text);
    
//    CommentStyle * secondStyle = [quoteStyles firstObject];
//    NSString * secondExpectedText = @"So Automattic, maker of the largest open source PHP CMS in the world has thrown out PHP in favor of node.js for their own site.";
//    
//    // Ensure that the complete quote was extracted without clipping
//    XCTAssert([firstStyle.text isEqualToString:expectedText]);
}

- (void)testInput4 {
    
    Comment * comment = [self createCommentFromInputFileWithName:
                         @"CommentTest-input-4.html"];
    
    NSArray * codeStyles = [comment.styles filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"type == %d", CommentStyleTypeCode]];
    NSArray * quoteStyles = [comment.styles filteredArrayUsingPredicate:
                             [NSPredicate predicateWithFormat:@"type == %d", CommentStyleTypeQuote]];
    
    // This particular example has one code style and one quote style
    XCTAssert([codeStyles count] == 1, @"One expected code style, found %lu",
              [codeStyles count]);
    XCTAssert([quoteStyles count] == 1, @"One expected quote style, found %lu",
              [quoteStyles count]);
}

#pragma mark - Private Methods
- (Comment*)createCommentFromInputFileWithName:(NSString*)filename {
    
    NSString * response = [self getResponseStringForFileWithName:filename];
    
    NSError * error = nil;
    Comment * comment = [MTLJSONAdapter modelOfClass:Comment.class
                                  fromJSONDictionary:@{ @"text": response } error:&error];
    if(error) {
        XCTFail(@"CommentTest, unable to create test comment, ERROR: %@", error);
        return nil;
    }
    return comment;
}

@end
