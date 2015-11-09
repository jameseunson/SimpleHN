//
//  LabelHelper.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "LabelHelper.h"

@implementation LabelHelper

+ (UILabel*)labelWithFont:(UIFont*)font {
    
    UILabel * label = [[UILabel alloc] init];
    
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return label;
}

@end
