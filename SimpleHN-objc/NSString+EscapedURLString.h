//
//  NSString+EscapedURLString.h
//  MyMonash
//
//  Created by James Eunson on 8/06/12.
//  Copyright (c) 2012 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EscapedURLString)
- (NSString*)escapedQueryString;
@end
