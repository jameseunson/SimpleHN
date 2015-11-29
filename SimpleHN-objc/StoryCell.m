//
//  StoryCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCell.h"
#import "StoryCommentsButton.h"
#import "ActionDrawerButton.h"
#import "TimeAgoInWords-Swift.h"

@interface StoryCell ()

@property (nonatomic, strong) NSLayoutConstraint * storyCommentsScoreRegularWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint * storyCommentsScoreCompactWidthConstraint;

@property (nonatomic, strong) NSLayoutConstraint * actionDrawerHeightConstraint;

@property (nonatomic, strong) UILabel * storyTitleLabel;
@property (nonatomic, strong) UILabel * storySubtitleLabel;
@property (nonatomic, strong) UIStackView * storyTitleSubtitleStackView;

@property (nonatomic, strong) StoryCommentsButton * storyCommentsButton;
@property (nonatomic, strong) UILabel * storyScoreLabel;
@property (nonatomic, strong) UIStackView * storyCommentsScoreStackView;

@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGestureRecognizer;

@property (nonatomic, strong) ActionDrawerView * actionDrawerView;
@property (nonatomic, strong) CALayer * actionDrawerBorderLayer;

- (void)didLongPressSelf:(id)sender;

@end

@implementation StoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
        _expanded = NO;
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(didLongPressSelf:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.6;
        [self addGestureRecognizer:_longPressGestureRecognizer];
        
        self.storyTitleSubtitleStackView = [[UIStackView alloc] init];
        
        _storyTitleSubtitleStackView.axis = UILayoutConstraintAxisVertical;
        _storyTitleSubtitleStackView.alignment = UIStackViewAlignmentLeading;
        _storyTitleSubtitleStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.storyTitleLabel = [LabelHelper labelWithFont:
                                [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
        [self.storyTitleSubtitleStackView addArrangedSubview:_storyTitleLabel];
        
        self.storySubtitleLabel = [LabelHelper labelWithFont:
                                   [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _storySubtitleLabel.textColor = [UIColor grayColor];
        
        [self.storyTitleSubtitleStackView addArrangedSubview:_storySubtitleLabel];
        [self.contentView addSubview:_storyTitleSubtitleStackView];
        
        self.storyCommentsScoreStackView = [[UIStackView alloc] init];

        _storyCommentsScoreStackView.axis = UILayoutConstraintAxisVertical;
        _storyCommentsScoreStackView.distribution = UIStackViewDistributionFill;
        _storyCommentsScoreStackView.alignment = UIStackViewAlignmentCenter;
        _storyCommentsScoreStackView.spacing = 8;
        _storyCommentsScoreStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        self.storyCommentsButton = [[StoryCommentsButton alloc] init];
        _storyCommentsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_storyCommentsScoreStackView addArrangedSubview:_storyCommentsButton];
        
        self.storyScoreLabel = [[UILabel alloc] init];
        _storyScoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _storyScoreLabel.textColor = [UIColor orangeColor];
        [_storyCommentsScoreStackView addArrangedSubview:_storyScoreLabel];
        
        [self.contentView addSubview:_storyCommentsScoreStackView];

        self.actionDrawerView = [[ActionDrawerView alloc] init];
        _actionDrawerView.translatesAutoresizingMaskIntoConstraints = NO;
        _actionDrawerView.delegate = self;
        [self.contentView addSubview:_actionDrawerView];
        
        self.actionDrawerBorderLayer = [CALayer layer];
        _actionDrawerBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        _actionDrawerBorderLayer.hidden = YES;
        [self.contentView.layer insertSublayer:_actionDrawerBorderLayer atIndex:100];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_storyTitleSubtitleStackView,
                                                                 _storyCommentsScoreStackView,
                                                                 _actionDrawerView);
       
        NSArray * verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_storyTitleSubtitleStackView]-[_actionDrawerView(44)]-|" options:0 metrics:nil views:bindings];
        
        for(NSLayoutConstraint * constraint in verticalConstraints) {
            if(constraint.constant == 44) {
                self.actionDrawerHeightConstraint = constraint;
            }
        }
        [self.contentView addConstraints:verticalConstraints];
        
        _actionDrawerHeightConstraint.constant = 0;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                              @"H:|-[_storyTitleSubtitleStackView]" options:0 metrics:nil views:bindings]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_storyCommentsScoreStackView]"
                                                                     options:0 metrics:nil views:bindings]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_storyTitleSubtitleStackView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeadingMargin multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_storyTitleSubtitleStackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.75 constant:0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_actionDrawerView]-|"
                                                                     options:0 metrics:nil views:bindings]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_storyCommentsScoreStackView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0]];
        
        self.storyCommentsScoreRegularWidthConstraint = [NSLayoutConstraint constraintWithItem:_storyCommentsScoreStackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.15 constant:0];
        
        self.storyCommentsScoreCompactWidthConstraint = [NSLayoutConstraint constraintWithItem:_storyCommentsScoreStackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.10 constant:0];
        
        if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            [self.contentView addConstraint:_storyCommentsScoreCompactWidthConstraint];
            
        } else {
            [self.contentView addConstraint:_storyCommentsScoreRegularWidthConstraint];
        }
        
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            self.normalBackgroundColor = UIColorFromRGB(0xffffff);
            self.nightBackgroundColor = UIColorFromRGB(0x333333);
            
            self.storyTitleLabel.normalTextColor = [UIColor blackColor];
            self.storyTitleLabel.nightTextColor = UIColorFromRGB(0x999999);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    _story = nil;
    
    _storyTitleLabel.text = nil;
    _storySubtitleLabel.text = nil;
    
    _storyCommentsButton.story = nil;
    _storyScoreLabel.text = nil;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
//    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
//        [self removeConstraint:_storyCommentsScoreRegularWidthConstraint];
//        [self addConstraint:_storyCommentsScoreCompactWidthConstraint];
//        
//    } else { // Regular and Unspecified
//        [self removeConstraint:_storyCommentsScoreCompactWidthConstraint];
//        [self addConstraint:_storyCommentsScoreRegularWidthConstraint];
//    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _actionDrawerBorderLayer.frame = CGRectMake(_actionDrawerView.frame.origin.x, _storyTitleSubtitleStackView.frame.origin.y + _storyTitleSubtitleStackView.frame.size.height + 8.0f, _actionDrawerView.frame.size.width, (1.0f / [[UIScreen mainScreen] scale]));
}

+ (void)handleActionForStory:(Story*)story withType:
    (NSNumber*)type inController:(UIViewController*)controller {
    
    NSLog(@"handleActionForStory: %@ with author: %@", story.title, story.author);
    
    ActionDrawerViewButtonType actionType = [type intValue];
    
    if(actionType == ActionDrawerViewButtonTypeUser) {
        NSLog(@"StoryActionDrawerViewButtonTypeUser");
        
        [controller performSegueWithIdentifier:@"showUser" sender:story.author];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:story.title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [controller presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Property Override Methods
- (void)setStory:(Story *)story {
    _story = story;
    
    self.storyTitleLabel.text = story.title;
    [_storyTitleLabel sizeToFit];
    
    if(story.url) {
        self.storySubtitleLabel.text = [NSString stringWithFormat:@"%@ · %@ · %@",
                                        story.url.host, story.author, [story.time timeAgoInWords]];
    } else {
        self.storySubtitleLabel.text = [NSString stringWithFormat:@"%@ · %@",
                                        story.author, [story.time timeAgoInWords]];
    }
    [_storySubtitleLabel sizeToFit];
    
    self.storyCommentsButton.story = story;
    
    _storyScoreLabel.text = [story.score stringValue];
    [_storyScoreLabel sizeToFit];

    [self setNeedsUpdateConstraints];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    
    if(expanded) {
        self.actionDrawerHeightConstraint.constant = 44;
        _actionDrawerBorderLayer.hidden = NO;
        
    } else {
        self.actionDrawerHeightConstraint.constant = 0;
        _actionDrawerBorderLayer.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (void)didLongPressSelf:(id)sender {
    NSLog(@"didLongPressSelf:");

    self.expanded = YES;
    
    if (self.longPressGestureRecognizer.state == UIGestureRecognizerStateBegan){
        if([self.delegate respondsToSelector:@selector(storyCellDidDisplayActionDrawer:)]) {
            [self.delegate performSelector:@selector(storyCellDidDisplayActionDrawer:) withObject:self];
        }
    }
}

#pragma mark -StoryActionDrawerViewDelegate Methods
- (void)actionDrawerView:(ActionDrawerView*)view
         didTapActionWithType:(NSNumber*)type {
    
    if([self.delegate respondsToSelector:@selector(storyCell:didTapActionWithType:)]) {
        [self.delegate performSelector:@selector(storyCell:didTapActionWithType:)
                            withObject:self withObject:type];
    }
}

@end
