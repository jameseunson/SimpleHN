//
//  LabelHelper.h
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "KILabel.h"
#import "TTTAttributedLabel.h"

@interface LabelHelper : NSObject

+ (UILabel*)labelWithFont:(UIFont*)font;
//+ (KILabel*)kiLabelWithFont:(UIFont*)font;
+ (TTTAttributedLabel*)tttLabelWithFont:(UIFont*)font;

// Dynamic type body font adjusted from the
// default 17pt to 16pt, which looks slightly less
// over-large
+ (UIFont*)adjustedBodyFont;
+ (UIFont*)adjustedItalicBodyFont;
+ (UIFont*)adjustedBoldBodyFont;
+ (UIFont*)adjustedMonospacedBodyFont;

@end
