//
//  LoginFieldTableViewCell.h
//  SimpleHN-objc
//
//  Created by James Eunson on 15/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoginFieldTableViewCellType) {
    LoginFieldTableViewCellTypeUsername = 0,
    LoginFieldTableViewCellTypePassword = 1
};

@protocol LoginFieldTableViewCellDelegate;
@interface LoginFieldTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) UITextField * field;
@property (nonatomic, assign) LoginFieldTableViewCellType type;

@property (nonatomic, assign) __unsafe_unretained id<LoginFieldTableViewCellDelegate> delegate;

@end

@protocol LoginFieldTableViewCellDelegate <NSObject>
- (void)loginFieldTableViewCell:(LoginFieldTableViewCell*)cell didChangeText:(NSString*)text;
@end
