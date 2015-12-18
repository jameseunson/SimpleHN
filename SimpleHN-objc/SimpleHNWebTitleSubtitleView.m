//
//  SimpleHNWebTitleSubtitleView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 18/12/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "SimpleHNWebTitleSubtitleView.h"

@interface SimpleHNWebTitleSubtitleView ()
- (void)didTapSelf:(id)sender;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;

@end

@implementation SimpleHNWebTitleSubtitleView

- (instancetype)init {
    if(self = [super init]) {
        
        self.titleLabel = [LabelHelper labelWithFont:[UIFont boldSystemFontOfSize:17.0f]];
        
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            _titleLabel.textColor = [UIColor whiteColor];
        } else {
            _titleLabel.textColor = [UIColor blackColor];
        }
        [self addSubview:_titleLabel];
        
        self.subtitleLabel = [LabelHelper labelWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self addSubview:_subtitleLabel];
        
        UITapGestureRecognizer * singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                               initWithTarget:self action:@selector(didTapSelf:)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGestureRecognizer];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSLog(@"%@", NSStringFromCGRect(_titleLabel.frame));
    
    CGFloat combinedHeight = _titleLabel.frame.size.height + _subtitleLabel.frame.size.height;
    CGFloat contentOrigin = roundf((self.frame.size.height / 2) - (combinedHeight / 2));
    
    _titleLabel.frame = CGRectMake(0, contentOrigin, self.frame.size.width, _titleLabel.frame.size.height);
    _subtitleLabel.frame = CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height,
                                      self.frame.size.width, _subtitleLabel.frame.size.height);
}

#pragma mark - Property Override Methods
- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    
    self.titleLabel.text = titleString;
    [self.titleLabel sizeToFit];
}
- (void)setSubtitleString:(NSString *)subtitleString {
    _subtitleString = subtitleString;
    
    self.subtitleLabel.text = subtitleString;
    [self.subtitleLabel sizeToFit];
}

#pragma mark - Private Methods
- (void)didTapSelf:(id)sender {
    if([self.delegate respondsToSelector:@selector(simpleHNWebTitleSubtitleViewDidTapView:)]) {
        [self.delegate performSelector:@selector(simpleHNWebTitleSubtitleViewDidTapView:) withObject:self];
    }
}

@end
