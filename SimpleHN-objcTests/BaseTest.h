//
//  TestBase.h
//  SimpleHN-objc
//
//  Created by James Eunson on 24/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BaseTest : XCTestCase
- (NSString*)getResponseStringForFileWithName:(NSString*)name;
@end
