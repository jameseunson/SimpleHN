//
//  NSString+EscapedURLString.m
//  MyMonash
//
//  Created by James Eunson on 8/06/12.
//  Copyright (c) 2012 JEON. All rights reserved.
//

#import "NSString+EscapedURLString.h"

@implementation NSString (EscapedURLString)

- (NSString*)escapedQueryString {
    
    NSString *escapedQuery = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (__bridge CFStringRef)self,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8);
    return escapedQuery;
}

@end
