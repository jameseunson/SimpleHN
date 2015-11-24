//
//  TestBase.m
//  SimpleHN-objc
//
//  Created by James Eunson on 24/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "BaseTest.h"

@implementation BaseTest

#pragma mark - Support Methods
- (NSString*)getResponseStringForFileWithName:(NSString*)name {
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath]
                          stringByAppendingPathComponent:name];
    NSError * error = nil;
    NSString * responseString = [NSString stringWithContentsOfFile:filePath encoding:
                                 NSUTF8StringEncoding error:&error];
    if(error) {
        XCTFail(); return nil;
    }
    
    return responseString;
}

@end
