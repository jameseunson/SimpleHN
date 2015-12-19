//
//  LoginFieldTableViewCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 15/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "LoginFieldTableViewCell.h"

@interface LoginFieldTableViewCell ()
- (void)textFieldValueChanged:(id)sender;
@end

@implementation LoginFieldTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.field = [[UITextField alloc] initWithFrame:CGRectZero];
        
        _field.delegate = self;
        
        [_field setAdjustsFontSizeToFitWidth:YES];
        _field.textColor = [UIColor blackColor];
        
        _field.backgroundColor = [UIColor clearColor];
        _field.autocorrectionType = UITextAutocorrectionTypeNo;
        _field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _field.textAlignment = NSTextAlignmentLeft;
        
        _field.font = [UIFont systemFontOfSize:18.0f];
        
        [_field addTarget:self action:@selector(textFieldValueChanged:)
            forControlEvents:UIControlEventEditingChanged];
        
        [_field setEnabled:YES];
        _field.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_field];
        
        [self.contentView addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:
                                          @"V:|-[_field]-|;H:|-[_field]-|" options:0 metrics:nil views:
                                          NSDictionaryOfVariableBindings(_field)]];
        
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            self.backgroundColor = UIColorFromRGB(0xffffff);
            self.nightBackgroundColor = kNightDefaultColor;
            
            self.field.textColor = UIColorFromRGB(0x000000);
            self.field.nightTextColor = UIColorFromRGB(0xffffff);
            
//            self.field.attributedPlaceholder
        }];
    }
    return self;
}

#pragma mark - Property Override Methods
- (void)setType:(LoginFieldTableViewCellType)type {
    _type = type;
    
    if(type == LoginFieldTableViewCellTypeUsername) {
        self.field.placeholder = @"Username";
        (self.field).returnKeyType = UIReturnKeyNext;
        
    } else {
        self.field.placeholder = @"Password";
        
        [self.field setSecureTextEntry:YES];
        (self.field).returnKeyType = UIReturnKeyDone;
    }
}

- (void)textFieldValueChanged:(id)sender {
    NSLog(@"textFieldValueChanged content: %@", self.field.text);
    
    if([self.delegate respondsToSelector:@selector(loginFieldTableViewCell:didChangeText:)]) {
        [self.delegate performSelector:@selector(loginFieldTableViewCell:didChangeText:)
                            withObject:self withObject:self.field.text];
    }
}

@end
