//
//  StoryDetailNoContentSelectedTableViewCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 19/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryDetailNoContentSelectedTableViewCell.h"

@interface StoryDetailNoContentSelectedTableViewCell ()

@property (nonatomic, strong) UILabel * noContentLabel;

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

@end

@implementation StoryDetailNoContentSelectedTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        

        
        self.noContentLabel = [LabelHelper labelWithFont:
                               [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        
        _noContentLabel.text = @"No story selected.";
        _noContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_noContentLabel sizeToFit];
        
        [self addSubview:_noContentLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_noContentLabel attribute:NSLayoutAttributeCenterY relatedBy:
                             NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_noContentLabel attribute:NSLayoutAttributeCenterX relatedBy:
                             NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionNightFallingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionDawnComingNotification object:nil];
        
        [self updateNightMode];
        
    }
    return self;
}

- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}

- (void)updateNightMode {
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        self.backgroundColor = kNightDefaultColor;
        _noContentLabel.textColor = UIColorFromRGB(0x999999);
    } else {
        self.backgroundColor = [UIColor whiteColor];
        _noContentLabel.textColor = RGBCOLOR(102, 102, 102);
    }
}
@end
