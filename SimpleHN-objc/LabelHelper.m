//
//  LabelHelper.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "LabelHelper.h"
//#import "UIFont+SSTextSize.h"

#define kBaseFontSize 17.0f

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

+ (TTTAttributedLabel*)tttLabelWithFont:(UIFont*)font {
    
    TTTAttributedLabel * label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.textColor = [UIColor blackColor];
    label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    
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
//    NSString * systemFontName = [[UIFont preferredFontForTextStyle:
//                                  UIFontTextStyleBody] fontName];
//    return [UIFont dynamicFontWithName:systemFontName baseSize:kBaseFontSize];
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

+ (UIFont*)adjustedItalicBodyFont {
//    return [UIFont dynamicFontWithName:[[UIFont italicSystemFontOfSize:
//                                         kBaseFontSize] fontName] baseSize:kBaseFontSize];
    
    UIFontDescriptor * descriptor = [[self adjustedBodyFont].fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont * font = [UIFont fontWithDescriptor:descriptor size:0];
    return font;
}

+ (UIFont*)adjustedBoldBodyFont {
//    return [UIFont dynamicFontWithName:[[UIFont boldSystemFontOfSize:
//                                         kBaseFontSize] fontName] baseSize:kBaseFontSize];
    UIFontDescriptor * descriptor = [[self adjustedBodyFont].fontDescriptor
                                     fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont * font = [UIFont fontWithDescriptor:descriptor size:0];
    return font;
}

+ (UIFont*)adjustedMonospacedBodyFont {
    
//    return [UIFont dynamicFontWithName:@"Menlo" baseSize:kBaseFontSize];    
    
    UIFontDescriptor * descriptor = [[self adjustedBodyFont].fontDescriptor
                                     fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitMonoSpace];
    UIFont * font = [UIFont fontWithDescriptor:descriptor size:0];
    return font;
}

@end
