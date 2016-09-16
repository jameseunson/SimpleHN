//
//  UserHeaderView.m
//  SimpleHN-objc
//
//  Created by James Eunson on 9/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "UserHeaderView.h"
#import "CommentTextView.h"
//#import "KILabel.h"

@interface UserHeaderView ()

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * submissionsLabel;
@property (nonatomic, strong) UILabel * accountCreatedLabel;

//@property (nonatomic, strong) UIStackView * mainStackView;

@property (nonatomic, strong) UILabel * karmaLabel;
@property (nonatomic, strong) UILabel * karmaSubtitleLabel;

//@property (nonatomic, strong) UIStackView * karmaStackView;

//@property (nonatomic, strong) UITextView * aboutTextView;
@property (nonatomic, strong) TTTAttributedLabel * aboutLabel;

@property (nonatomic, strong) UIToolbar * toolbar;
@property (nonatomic, strong) UISegmentedControl * sectionSegmentedControl;

- (void)didChangeSegment:(id)sender;

- (void)nightModeEvent:(NSNotification*)notification;
- (void)updateNightMode;

@end

@implementation UserHeaderView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        
        _visibleData = UserHeaderViewVisibleDataAll;
        
        self.nameLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        [self addSubview:_nameLabel];
        
        self.submissionsLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _submissionsLabel.textColor = [UIColor grayColor];
        [self addSubview:_submissionsLabel];
        
        self.accountCreatedLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _accountCreatedLabel.textColor = [UIColor grayColor];
        [self addSubview:_accountCreatedLabel];
        
        self.karmaLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        _karmaLabel.textColor = [UIColor orangeColor];
        _karmaLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_karmaLabel];
        
        self.karmaSubtitleLabel = [LabelHelper labelWithFont:
                           [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _karmaSubtitleLabel.textColor = [UIColor grayColor];
        _karmaSubtitleLabel.text = @"karma";
        _karmaSubtitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_karmaSubtitleLabel];
        
        self.aboutLabel = [LabelHelper tttLabelWithFont:[LabelHelper adjustedBodyFont]];
        _aboutLabel.delegate = self;
        [self addSubview:_aboutLabel];
        
        self.toolbar = [[UIToolbar alloc] init];
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            _toolbar.barTintColor = kNightDefaultColor;
            _toolbar.translucent = NO;
            
        } else {
            _toolbar.barTintColor = [UIColor whiteColor];
            _toolbar.translucent = YES;
        }
        _toolbar.tintColor = [UIColor orangeColor];
        
        self.sectionSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"All", @"Submissions", @"Comments" ]];
        _sectionSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        _sectionSegmentedControl.selectedSegmentIndex = 0;
        [_sectionSegmentedControl addTarget:self action:
            @selector(didChangeSegment:) forControlEvents:UIControlEventValueChanged];
        
        [_toolbar addSubview:_sectionSegmentedControl];
        
        [self addSubview:_toolbar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionNightFallingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeEvent:)
                                                     name:DKNightVersionDawnComingNotification object:nil];
        
        [self updateNightMode];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat margin = 12.0f;
    
    CGSize sizeForNameLabel = [_nameLabel.text sizeWithAttributes:@{ NSFontAttributeName: _nameLabel.font }];
    self.nameLabel.frame = CGRectIntegral( CGRectMake(margin, margin, sizeForNameLabel.width, sizeForNameLabel.height) );
    
    CGSize sizeForSubmissionsLabel = [_submissionsLabel.text sizeWithAttributes:@{ NSFontAttributeName: _submissionsLabel.font }];
    self.submissionsLabel.frame = CGRectIntegral( CGRectMake(margin, _nameLabel.frame.origin.y + _nameLabel.frame.size.height,
                                                             sizeForSubmissionsLabel.width, sizeForSubmissionsLabel.height) );
    
    CGSize sizeForAcountCreatedLabel = [_accountCreatedLabel.text sizeWithAttributes:@{ NSFontAttributeName: _accountCreatedLabel.font }];
    self.accountCreatedLabel.frame = CGRectIntegral( CGRectMake(margin, _submissionsLabel.frame.origin.y + _submissionsLabel.frame.size.height,
                                                             sizeForAcountCreatedLabel.width, sizeForAcountCreatedLabel.height) );
    
    CGSize sizeForKarmaLabel = [_karmaLabel.text sizeWithAttributes:@{ NSFontAttributeName: _karmaLabel.font }];
    self.karmaLabel.frame = CGRectIntegral( CGRectMake(self.frame.size.width - sizeForKarmaLabel.width - margin, margin,
                                                       sizeForKarmaLabel.width, sizeForKarmaLabel.height) );
    
    CGSize sizeForKarmaSubtitleLabel = [_karmaSubtitleLabel.text sizeWithAttributes:@{ NSFontAttributeName: _karmaSubtitleLabel.font }];
    self.karmaSubtitleLabel.frame = CGRectIntegral( CGRectMake(self.frame.size.width - sizeForKarmaSubtitleLabel.width - margin, _karmaLabel.frame.origin.y + _karmaLabel.frame.size.height,
                                                       sizeForKarmaSubtitleLabel.width, sizeForKarmaSubtitleLabel.height) );
    
    CGFloat aboutLabelYOffset = MAX((margin + sizeForNameLabel.height + sizeForSubmissionsLabel.height + sizeForAcountCreatedLabel.height + margin), (margin + sizeForKarmaLabel.height + sizeForKarmaSubtitleLabel.height + sizeForAcountCreatedLabel.height + margin));
    
    CGSize sizeForAboutLabel = [TTTAttributedLabel sizeThatFitsAttributedString:self.user.attributedAboutText withConstraints:
                           CGSizeMake((self.frame.size.width - (margin * 2)), CGFLOAT_MAX) limitedToNumberOfLines:0];
    self.aboutLabel.frame = CGRectMake(margin, aboutLabelYOffset, sizeForAboutLabel.width, sizeForAboutLabel.height);
    
    self.toolbar.frame = CGRectMake(margin, _aboutLabel.frame.origin.y + _aboutLabel.frame.size.height + margin,
                                    self.frame.size.width - (margin * 2), 44.0f);
    self.sectionSegmentedControl.frame = CGRectMake(0, 0, self.frame.size.width - (margin * 2), 33.0f);
    
    [self invalidateIntrinsicContentSize];
}

+ (CGFloat)heightWithUser:(User*)user forWidth:(CGFloat)width {
    
    CGFloat margin = 12.0f;
    CGFloat heightAccumulator = margin;
    
    CGSize sizeForNameLabel = [user.name sizeWithAttributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3] }];
    CGSize sizeForSubmissionsLabel = [user.accountCreatedString sizeWithAttributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1] }];
    CGSize sizeForAcountCreatedLabel = [user.submissionsString sizeWithAttributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1] }];
    
    CGFloat aboutLabelYOffset = (margin + sizeForNameLabel.height + sizeForSubmissionsLabel.height + sizeForAcountCreatedLabel.height + margin);
    
    CGSize sizeForAboutLabel = [TTTAttributedLabel sizeThatFitsAttributedString:user.attributedAboutText withConstraints:
                                CGSizeMake((width - (margin * 2)), CGFLOAT_MAX) limitedToNumberOfLines:0];
    
    heightAccumulator += aboutLabelYOffset + sizeForAboutLabel.height + margin + 44.0f;
    return heightAccumulator;
}

#pragma mark - Private Methods
- (void)nightModeEvent:(NSNotification*)notification {
    [self updateNightMode];
}


- (void)updateNightMode {

    if([[AppConfig sharedConfig] nightModeEnabled]) {
        
        self.nameLabel.textColor = UIColorFromRGB(0xffffff);
        self.toolbar.barTintColor = kNightDefaultColor;
        self.backgroundColor = kNightDefaultColor;
        
    } else {
        self.nameLabel.textColor = [UIColor blackColor];
        self.toolbar.barTintColor = [UIColor whiteColor];
        self.backgroundColor = UIColorFromRGB(0xffffff);
    }
    
    if(_user.about) {
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            self.aboutLabel.text = _user.nightAttributedAboutText;
            self.aboutLabel.linkAttributes = @{ NSForegroundColorAttributeName: [UIColor orangeColor],
                                                NSUnderlineStyleAttributeName: @(1) };
        } else {
            
            self.aboutLabel.text = _user.attributedAboutText;
            self.aboutLabel.linkAttributes = @{ NSForegroundColorAttributeName: RGBCOLOR(0, 0, 238),
                                                NSUnderlineStyleAttributeName: @(1) };
        }
    }
}

#pragma mark - Property Override Methods
- (void)setUser:(User *)user {
    _user = user;
    
    self.nameLabel.text = _user.name;
    self.accountCreatedLabel.text = _user.accountCreatedString;
    self.submissionsLabel.text = _user.submissionsString;
    
    self.karmaLabel.text = [_user.karma stringValue];
    
    if(_user.about) {
        
        if([[AppConfig sharedConfig] nightModeEnabled]) {
            self.aboutLabel.text = _user.nightAttributedAboutText;
            self.aboutLabel.linkAttributes = @{ NSForegroundColorAttributeName: [UIColor orangeColor],
                                                NSUnderlineStyleAttributeName: @(1) };
        } else {
            
            self.aboutLabel.text = _user.attributedAboutText;
            self.aboutLabel.linkAttributes = @{ NSForegroundColorAttributeName: RGBCOLOR(0, 0, 238),
                                                NSUnderlineStyleAttributeName: @(1) };
        }
    }
    
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)didChangeSegment:(id)sender {
    self.visibleData = (int)self.sectionSegmentedControl.selectedSegmentIndex;
    
    if([self.delegate respondsToSelector:@selector(userHeaderView:didChangeVisibleData:)]) {
        [self.delegate performSelector:@selector(userHeaderView:didChangeVisibleData:)
                            withObject:self withObject:@(_visibleData)];
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    
    if([[self.user.linksLookup allKeys] containsObject:url.absoluteString]) {
        NSString * substituteURLString = self.user.linksLookup[url.absoluteString];
        url = [NSURL URLWithString:substituteURLString];
    }
    
    if([self.delegate respondsToSelector:@selector(userHeaderView:didTapLink:)]) {
        [self.delegate performSelector:@selector(userHeaderView:didTapLink:)
                            withObject:self withObject:url];
    }
}

@end
