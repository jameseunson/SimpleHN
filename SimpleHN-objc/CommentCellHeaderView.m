//
//  CommentCellHeaderView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 4/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "CommentCellHeaderView.h"
#import "TimeAgoInWords-Swift.h"

#define kHeaderDownIcon @"▼"
#define kHeaderUpIcon @"▲"

@interface CommentCellHeaderView ()

@property (nonatomic, strong) UILabel * authorLabel;
@property (nonatomic, strong) UILabel * dateLabel;

@property (nonatomic, strong) CALayer * headerBorderLayer;
@property (nonatomic, strong) UIView * headerBackgroundView;
@property (nonatomic, strong) UILabel * headerUpDownLabel;

- (void)didTouchDown:(id)sender;

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

@property (nonatomic, strong) NSLayoutConstraint * headerStackHorizontalInsetConstraint;

@end

@implementation CommentCellHeaderView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if(self = [super init]) {
        
        _collapsed = NO;
        
        self.headerUpDownLabel = [LabelHelper labelWithFont:
                                  [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _headerUpDownLabel.text = kHeaderUpIcon;
        _headerUpDownLabel.textColor = [UIColor orangeColor];
        _headerUpDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_headerUpDownLabel];
        
        self.authorLabel = [LabelHelper labelWithFont:
                            [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _authorLabel.textColor = [UIColor orangeColor];
        _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_authorLabel];
        
        self.dateLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _dateLabel.textColor = [UIColor grayColor];
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_dateLabel];
        
        self.headerBorderLayer = [CALayer layer];
        _headerBorderLayer.backgroundColor = [RGBCOLOR(215, 215, 215) CGColor];
        [self.layer insertSublayer:_headerBorderLayer atIndex:100];
        
        // Explanation of syntax https://github.com/mikeswanson/JBNSLayoutConstraint used for brevity
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_dateLabel, _authorLabel, _headerUpDownLabel);
        
        NSArray * headerConstraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"_dateLabel.centerY==|.centerY;_headerUpDownLabel.centerY==|.centerY;_authorLabel.centerY==|.centerY;H:|-20-[_headerUpDownLabel]-[_authorLabel];H:[_dateLabel]-|" options:0 metrics:nil views:bindings];
        
        for(NSLayoutConstraint * constraint in headerConstraints) {
            if(constraint.constant == 20) {
                self.headerStackHorizontalInsetConstraint = constraint;
            }
        }
        [self addConstraints:headerConstraints];
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(didTouchDown:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        [self updateNightMode];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionNightFallingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionDawnComingNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightForBorder = (1.0 / [UIScreen mainScreen].scale);
    _headerBorderLayer.frame = CGRectMake(0, self.frame.origin.y +
                                          self.frame.size.height + 4.0f,
                                          self.frame.size.width, heightForBorder);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 30.0f);
}

#pragma mark - Property Override Methods
- (void)setComment:(Comment *)comment {
    _comment = comment;
    
    self.authorLabel.text = comment.author;
    self.dateLabel.text = [comment.time timeAgoInWords];
    
    self.headerStackHorizontalInsetConstraint.constant = (20 * (comment.indentation + 1));
}

- (void)setCollapsed:(BOOL)collapsed {
    _collapsed = collapsed;
    
    if(collapsed) {
        self.headerUpDownLabel.text = kHeaderDownIcon;
        self.headerUpDownLabel.textColor = [UIColor grayColor];
        self.authorLabel.textColor = [UIColor grayColor];
        self.headerBorderLayer.hidden = YES;
        
    } else {
        
        self.headerUpDownLabel.text = kHeaderUpIcon;
        self.headerUpDownLabel.textColor = [UIColor orangeColor];
        self.authorLabel.textColor = [UIColor orangeColor];
        self.headerBorderLayer.hidden = NO;
    }
}

- (void)didTouchDown:(id)sender {
    NSLog(@"didTouchDown");
}

- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}

- (void)updateNightMode {
    
    if([[AppConfig sharedConfig] nightModeEnabled]) {
        _headerBorderLayer.backgroundColor = [UIColorFromRGB(0x555555) CGColor];
    } else {
        _headerBorderLayer.backgroundColor = [RGBCOLOR(215, 215, 215) CGColor];
    }
}

@end
