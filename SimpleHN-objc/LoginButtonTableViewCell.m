//
//  LoginButtonTableViewCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 15/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "LoginButtonTableViewCell.h"

@implementation LoginButtonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = [UIFont systemFontOfSize:18.0f];
        self.textLabel.textColor = [UIColor orangeColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
