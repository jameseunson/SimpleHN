//
//  TopStoriesTitleView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "TopStoriesTitleView.h"

@interface TopStoriesTitleView ()
- (void)didTapSelf:(id)sender;
@end

@implementation TopStoriesTitleView

- (instancetype)init {
    if(self = [super init]) {
        
        NSString * baseTitleString = @"Top ˅";
        NSMutableAttributedString * titleAttributedString = [[NSMutableAttributedString alloc] initWithString:baseTitleString];
        [titleAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:[baseTitleString rangeOfString:@"˅"]];
        [titleAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Menlo-Regular" size:17.0f] range:[baseTitleString rangeOfString:@"˅"]];
        
        self.titleLabel = [LabelHelper labelWithFont:[UIFont boldSystemFontOfSize:17.0f]];
        _titleLabel.attributedText = titleAttributedString;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        
        self.subtitleLabel = [LabelHelper labelWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.text = @"Now";
        _subtitleLabel.textColor = [UIColor grayColor];
        [_subtitleLabel sizeToFit];
        
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

#pragma mark - Private Methods
- (void)didTapSelf:(id)sender {
    if([self.delegate respondsToSelector:@selector(topStoriesTitleViewDidTapTitleView:)]) {
        [self.delegate performSelector:@selector(topStoriesTitleViewDidTapTitleView:) withObject:self];
    }
}

@end
