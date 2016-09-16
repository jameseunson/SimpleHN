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

- (void)didTapInputAccessoryPrevItem:(id)sender;
- (void)didTapInputAccessoryNextItem:(id)sender;
- (void)didTapInputAccessoryDoneItem:(id)sender;

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
        
        UIToolbar * inputAccessoryToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.0f)];
        inputAccessoryToolbar.tintColor = [UIColor orangeColor];
        inputAccessoryToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.nextBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:
                                  UIBarButtonItemStylePlain target:self action:@selector(didTapInputAccessoryNextItem:)];
        self.prevBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:
                                  UIBarButtonItemStylePlain target:self action:@selector(didTapInputAccessoryPrevItem:)];
        
        UIBarButtonItem * flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                               UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem * doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                      UIBarButtonSystemItemDone target:self action:@selector(didTapInputAccessoryDoneItem:)];
        
        [inputAccessoryToolbar setItems:@[ _prevBarButtonItem, _nextBarButtonItem, flexibleSpaceItem, doneItem ]];
        _field.inputAccessoryView = inputAccessoryToolbar;
        
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            self.backgroundColor = UIColorFromRGB(0xffffff);
            self.nightBackgroundColor = kNightDefaultColor;
            
            self.field.textColor = UIColorFromRGB(0x000000);
            self.field.nightTextColor = UIColorFromRGB(0xffffff);
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
    if([self.delegate respondsToSelector:@selector(loginFieldTableViewCell:didChangeText:)]) {
        [self.delegate performSelector:@selector(loginFieldTableViewCell:didChangeText:)
                            withObject:self withObject:self.field.text];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(loginFieldTableViewCell:didStartEditing:)]) {
        [self.delegate performSelector:@selector(loginFieldTableViewCell:didStartEditing:) withObject:self withObject:textField];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(loginFieldTableViewCell:didEndEditing:)]) {
        [self.delegate performSelector:@selector(loginFieldTableViewCell:didEndEditing:) withObject:self withObject:textField];
    }
}

#pragma mark - Private Methods
- (void)didTapInputAccessoryPrevItem:(id)sender {
    if([self.delegate respondsToSelector:@selector(loginFieldTableViewCell:didTapPreviousButton:)]) {
        [self.delegate performSelector:@selector(loginFieldTableViewCell:didTapPreviousButton:) withObject:self withObject:sender];
    }
}
- (void)didTapInputAccessoryNextItem:(id)sender {
    if([self.delegate respondsToSelector:@selector(loginFieldTableViewCell:didTapNextButton:)]) {
        [self.delegate performSelector:@selector(loginFieldTableViewCell:didTapNextButton:) withObject:self withObject:sender];
    }
}
- (void)didTapInputAccessoryDoneItem:(id)sender {
    if([self.delegate respondsToSelector:@selector(loginFieldTableViewCell:didTapDoneButton:)]) {
        [self.delegate performSelector:@selector(loginFieldTableViewCell:didTapDoneButton:) withObject:self withObject:sender];
    }
}

@end
