//
//  HNSessionAPIManager.h
//  SimpleHN-objc
//
//  Created by James Eunson on 15/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNSessionAPIManager : NSObject

+ (HNSessionAPIManager*)sharedManager;

- (void)performLoginWithUsername:(NSString*)username password:(NSString*)password completion: (void (^)(NSDictionary * result))completion;

@end
