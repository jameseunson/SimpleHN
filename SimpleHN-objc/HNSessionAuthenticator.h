//
//  HNSessionAuthenticator.h
//  SimpleHN-objc
//
//  Created by James Eunson on 15/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HNSessionAuthenticatorCompletion)(User* user);
@interface HNSessionAuthenticator : NSObject

- (void)loginWithUsername:(NSString*)username password:(NSString*)password completion:(HNSessionAuthenticatorCompletion)completion;

@end
