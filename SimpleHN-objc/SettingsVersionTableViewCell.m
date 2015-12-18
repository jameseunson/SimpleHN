//
//  SettingsVersionTableViewCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 18/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "SettingsVersionTableViewCell.h"

@implementation SettingsVersionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.textLabel.text = @"Version";
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                     [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                                     [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
