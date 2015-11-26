//
//  LabelHelper.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "LabelHelper.h"
#import "UIFont+SSTextSize.h"

#define kBaseFontSize 15.0f

@implementation LabelHelper

+ (UILabel*)labelWithFont:(UIFont*)font {
    
    UILabel * label = [[UILabel alloc] init];
    
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.textColor = [UIColor blackColor];
    
    return label;
}

//+ (KILabel*)kiLabelWithFont:(UIFont*)font {
//    
//    KILabel * label = [[KILabel alloc] init];
//    
//    label.backgroundColor = [UIColor clearColor];
//    label.font = font;
//    
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.numberOfLines = 0;
//    label.textColor = [UIColor blackColor];
//    label.automaticLinkDetectionEnabled = YES;
//    
//    return label;
//}

+ (UIFont*)adjustedBodyFont {
    NSString * systemFontName = [[UIFont preferredFontForTextStyle:
                                  UIFontTextStyleBody] fontName];
    return [UIFont dynamicFontWithName:systemFontName baseSize:kBaseFontSize];
}

+ (UIFont*)adjustedItalicBodyFont {
    return [UIFont dynamicFontWithName:[[UIFont italicSystemFontOfSize:
                                         kBaseFontSize] fontName] baseSize:kBaseFontSize];
}

+ (UIFont*)adjustedBoldBodyFont {
    return [UIFont dynamicFontWithName:[[UIFont boldSystemFontOfSize:
                                         kBaseFontSize] fontName] baseSize:kBaseFontSize];
}

+ (UIFont*)adjustedMonospacedBodyFont {
    return [UIFont dynamicFontWithName:@"Menlo" baseSize:kBaseFontSize];
}

@end
