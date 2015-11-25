//
//  CommentCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 2/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "CommentCell.h"
#import "TimeAgoInWords-Swift.h"
#import "UIFont+SSTextSize.h"
#import "JBNSLayoutConstraint+Install.h"
#import "ActionDrawerButton.h"
#import "RegexKitLite.h"

@import SafariServices;

#define kHeaderDownIcon @"▼"
#define kHeaderUpIcon @"▲"

@interface CommentCell ()

@property (nonatomic, strong) NSLayoutConstraint * headerStackHorizontalInsetConstraint;
@property (nonatomic, strong) NSLayoutConstraint * labelHorizontalInsetConstraint;

// Joins the trailing edge of the stackview to a spacer, to the
// leading edge of the label, used when collapsed = NO
@property (nonatomic, strong) NSLayoutConstraint * stackViewLabelJoinConstraint;
@property (nonatomic, strong) NSLayoutConstraint * labelDrawerJoinConstraint;
@property (nonatomic, strong) NSLayoutConstraint * drawerBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint * actionDrawerHeightConstraint;

// Comments which aren't root-level are completely hidden when a parent is hidden
// headerViewHeightConstraint.constant is configured to be 0
@property (nonatomic, strong) NSLayoutConstraint * headerViewHeightConstraint;

// Used to stick the stackview to the bottom of the contentView,
// when the cell is collapsed, used when collapsed = YES
@property (nonatomic, strong) NSLayoutConstraint * headerViewBottomConstraint;

@property (nonatomic, strong) UITapGestureRecognizer * headerBackgroundViewTapGestureRecognizer;

@property (nonatomic, strong) ActionDrawerView * actionDrawerView;
@property (nonatomic, strong) CALayer * actionDrawerBorderLayer;

@property (nonatomic, strong) NSArray * blockQuoteRanges;

- (void)didTapBackgroundView:(id)sender;

- (void)commentCollapsedChanged:(NSNotification*)notification;

- (void)collapseCell;
- (void)uncollapseCell;

@end

@implementation CommentCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        _expanded = NO;
        
        self.commentTextView = [[UITextView alloc] init];
        _commentTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _commentTextView.scrollEnabled = NO;
        _commentTextView.editable = NO;
        _commentTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _commentTextView.selectable = YES;
        _commentTextView.delegate = self;
        [self.contentView addSubview:_commentTextView];
        
        self.headerView = [[UIView alloc] init];
        _headerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.headerUpDownLabel = [LabelHelper labelWithFont:
                                  [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _headerUpDownLabel.text = kHeaderUpIcon;
        _headerUpDownLabel.textColor = [UIColor orangeColor];
        _headerUpDownLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [_headerView addSubview:_headerUpDownLabel];
        
        self.authorLabel = [LabelHelper labelWithFont:
                            [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _authorLabel.textColor = [UIColor orangeColor];
        _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_headerView addSubview:_authorLabel];
        
        self.dateLabel = [LabelHelper labelWithFont:
                          [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        _dateLabel.textColor = [UIColor grayColor];
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_headerView addSubview:_dateLabel];
        
        _headerView.userInteractionEnabled = NO;
        [self.contentView addSubview:_headerView];
        
        self.headerBackgroundView = [[UIView alloc] init];
        _headerBackgroundView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_headerBackgroundView];
        
        self.headerBackgroundViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(didTapBackgroundView:)];
        [_headerBackgroundView addGestureRecognizer:_headerBackgroundViewTapGestureRecognizer];
        [self.contentView sendSubviewToBack:_headerBackgroundView];
        
        self.headerBorderLayer = [CALayer layer];
        _headerBorderLayer.backgroundColor = [RGBCOLOR(215, 215, 215) CGColor];
        [self.layer insertSublayer:_headerBorderLayer atIndex:100];
        
        self.actionDrawerView = [[ActionDrawerView alloc] init];
        _actionDrawerView.translatesAutoresizingMaskIntoConstraints = NO;
        _actionDrawerView.delegate = self;
        [self.contentView addSubview:_actionDrawerView];
        
        self.actionDrawerBorderLayer = [CALayer layer];
        _actionDrawerBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        _actionDrawerBorderLayer.hidden = YES;
        [self.contentView.layer insertSublayer:_actionDrawerBorderLayer atIndex:100];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_commentTextView, _headerView, _actionDrawerView, _dateLabel, _authorLabel, _headerUpDownLabel);
        
        self.headerViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_headerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0];
        
        NSArray * verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:
                                         @"V:|-[_headerView(20)]-10-[_commentTextView]-10-[_actionDrawerView(44)]-|" options:0 metrics:nil views:bindings];
        int i = 0;
        for(NSLayoutConstraint * constraint in verticalConstraints) {
            if(constraint.constant == 10 && constraint.firstItem == self.commentTextView) {
//            if(constraint.constant == 10 && constraint.firstItem == self.commentLabel) {
                self.stackViewLabelJoinConstraint = constraint;
                
            } else if(constraint.constant == 10 && constraint.firstItem == self.actionDrawerView) {
                self.labelDrawerJoinConstraint = constraint;
                
            } else if(constraint.firstItem == self.contentView
                      && constraint.firstAttribute == NSLayoutAttributeBottomMargin) {
                self.drawerBottomConstraint = constraint;
            
            } else if(constraint.constant == 20) {
                self.headerViewHeightConstraint = constraint;
                
            } else if(constraint.constant == 44) {
                self.actionDrawerHeightConstraint = constraint;
            }
            i++;
        }
        _actionDrawerHeightConstraint.constant = 0;
        [self.contentView addConstraints:verticalConstraints];
        
        [self.contentView addConstraints:[NSLayoutConstraint jb_constraintsWithVisualFormat:@"H:|-[_actionDrawerView]-|;H:|-0-[_headerView]-|"
                                                                                 options:0 metrics:nil views:bindings]];
        
        // commentLabel constraints
//        NSArray * labelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:
//                                                @"H:|-20-[_commentLabel]-|" options:0 metrics:nil views:bindings];
        NSArray * labelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:
                                                @"H:|-20-[_commentTextView]-|" options:0 metrics:nil views:bindings];
        
        for(NSLayoutConstraint * constraint in labelHorizontalConstraints) {
            if(constraint.constant == 20) {
                self.labelHorizontalInsetConstraint = constraint;
            }
        }
        [self.contentView addConstraints:labelHorizontalConstraints];
        
        // Explanation of syntax https://github.com/mikeswanson/JBNSLayoutConstraint used for brevity
        NSArray * headerConstraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"_dateLabel.centerY==|.centerY;_headerUpDownLabel.centerY==|.centerY;_authorLabel.centerY==|.centerY;H:|-20-[_headerUpDownLabel]-[_authorLabel];H:[_dateLabel]-|" options:0 metrics:nil views:bindings];
        
        for(NSLayoutConstraint * constraint in headerConstraints) {
            if(constraint.constant == 20) {
                self.headerStackHorizontalInsetConstraint = constraint;
            }
        }
        [self.headerView addConstraints:headerConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCollapsedChanged:)
                                                     name:kCommentCollapsedChanged object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightForBorder = (1.0 / [UIScreen mainScreen].scale);
    _headerBorderLayer.frame = CGRectMake(0, _headerView.frame.origin.y +
                                          _headerView.frame.size.height + 4.0f,
                                          self.frame.size.width, heightForBorder);
    
    _headerBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width,
                                             _headerView.frame.size.height + 5.0f);
    
//    _actionDrawerBorderLayer.frame = CGRectMake(_actionDrawerView.frame.origin.x, _commentLabel.frame.origin.y + _commentLabel.frame.size.height + 8.0f, _actionDrawerView.frame.size.width, (1.0f / [[UIScreen mainScreen] scale]));
    _actionDrawerBorderLayer.frame = CGRectMake(_actionDrawerView.frame.origin.x, _commentTextView.frame.origin.y + _commentTextView.frame.size.height + 8.0f, _actionDrawerView.frame.size.width, (1.0f / [[UIScreen mainScreen] scale]));
}

- (void)prepareForReuse {
    
    // Cell is in collapsed configuration
    if([self.contentView.constraints containsObject:_headerViewBottomConstraint]) {
        [self uncollapseCell];
    }
    
    self.commentTextView.attributedText = nil;
//    self.commentLabel.text = nil;
    
    self.authorLabel.text = nil;
    self.dateLabel.text = nil;
}

+ (void)handleActionForComment:(Comment *)comment withType:(NSNumber *)type inController:(UIViewController *)controller {
    ActionDrawerViewButtonType actionType = [type intValue];
    
    if(actionType == ActionDrawerViewButtonTypeUser) {
        NSLog(@"ActionDrawerViewButtonTypeUser");
        
        [comment loadUserForComment:^(User *user) {
            [controller performSegueWithIdentifier:@"showUser" sender:user];
        }];
        
    } else if(actionType == ActionDrawerViewButtonTypeMore) {
        NSLog(@"ActionDrawerViewButtonTypeMore");
        
        NSString * title = [NSString stringWithFormat:@"Comment from %@", comment.author];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [controller presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Property Override Methods
- (void)setComment:(Comment *)comment {
    _comment = comment;
    
    if(comment.text != nil) {
        
        NSString * commentSourceText = nil;
        
        if([comment.text rangeOfRegex: [CommentStyle openTagForType: CommentStyleTypeQuote]].location != NSNotFound) {
            
            NSMutableString * mutableText = [[NSMutableString alloc] initWithString:comment.text];
            [mutableText insertString:@"<style>blockquote{ color: #999999; }</style>" atIndex:0];
            
            while([mutableText rangeOfRegex: [CommentStyle openTagForType: CommentStyleTypeQuote]].location != NSNotFound) {
                
                NSRange rangeOfOpenTag = [mutableText rangeOfRegex:
                                          [CommentStyle openTagForType: CommentStyleTypeQuote]];
                NSString * matchedString = [mutableText stringByMatching:
                                            [CommentStyle openTagForType: CommentStyleTypeQuote]];
                
                NSLog(@"quote detected: %@, %@", NSStringFromRange(rangeOfOpenTag), matchedString);
                
                NSString * blockQuoteString = nil;
                NSScanner * scanner = [NSScanner scannerWithString:mutableText];
                
                scanner.scanLocation = rangeOfOpenTag.location + [matchedString length];
                [scanner scanUpToString:@"<p>" intoString:&blockQuoteString];
                
                [mutableText deleteCharactersInRange:rangeOfOpenTag];
                [mutableText insertString:@"<blockquote>" atIndex:rangeOfOpenTag.location];
                
                if(blockQuoteString && [blockQuoteString length] > 0) {
                    
                    NSLog(@"blockQuoteString: %@", blockQuoteString);
                    
                    NSRange blockQuoteRange = [mutableText rangeOfString:blockQuoteString];
                    [mutableText insertString:@"</blockquote><p></p>" atIndex:
                     (blockQuoteRange.location + blockQuoteRange.length)];
                    
                    NSLog(@"mutableText: %@", mutableText);
                    
                } else {
                    
                    [mutableText insertString:@"</blockquote>" atIndex:mutableText.length];
                }
            }
            
            commentSourceText = [mutableText copy];
            
        } else {
            commentSourceText = comment.text;
        }

        NSMutableAttributedString * commentText = [[[NSAttributedString alloc] initWithData:[commentSourceText dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                         documentAttributes:nil error:nil] mutableCopy];
        
        NSRange range = (NSRange){0, [commentText length]};
        [commentText enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            UIFont* currentFont = value;
           
            if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
//                NSLog(@"currentFont: %@ BOLD", [currentFont fontName]);
                [commentText addAttribute:NSFontAttributeName
                                    value:[LabelHelper adjustedBoldBodyFont] range:range];
                
            } else if ([currentFont.fontName rangeOfString:@"italic" options:NSCaseInsensitiveSearch].location != NSNotFound) {
//                NSLog(@"currentFont: %@ ITALIC", [currentFont fontName]);
                [commentText addAttribute:NSFontAttributeName
                                    value:[LabelHelper adjustedItalicBodyFont] range:range];
            } else {
//                NSLog(@"currentFont: %@", [currentFont fontName]);
                [commentText addAttribute:NSFontAttributeName
                                    value:[LabelHelper adjustedBodyFont] range:range];
            }

        }];
        
        NSMutableArray * mutableBlockQuoteRanges = [[NSMutableArray alloc] init];
        [commentText enumerateAttribute:NSForegroundColorAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            
            UIColor * colorValue = value;
            if(![colorValue isEqual:[UIColor blackColor]]) {
                // Block quote
                [mutableBlockQuoteRanges addObject:@[ @(range.location), @(range.length) ]];
            }
        }];
        
        for(NSArray * rangeArray in mutableBlockQuoteRanges) {
            NSLog(@"%@", rangeArray);
        }
        
        self.blockQuoteRanges = [mutableBlockQuoteRanges copy];
        
//        self.commentLabel.attributedText = commentText;
        self.commentTextView.attributedText = commentText;
    }
    
    if(self.comment.collapsed) {
        [self collapseCell];
    } else {
        [self uncollapseCell];
    }

    self.labelHorizontalInsetConstraint.constant = (20 * (comment.indentation + 1));
    self.headerStackHorizontalInsetConstraint.constant = (20 * (comment.indentation + 1));
    
    self.authorLabel.text = comment.author;
    self.dateLabel.text = [comment.time timeAgoInWords];
    
    [self setNeedsLayout];
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    
//    if(self.comment.collapsed) {
//        [self uncollapseCell];
//    }
    
    if(expanded) {
        self.actionDrawerHeightConstraint.constant = 44;
        _actionDrawerBorderLayer.hidden = NO;
        
        self.labelHorizontalInsetConstraint.constant = 20;
        self.headerStackHorizontalInsetConstraint.constant = 20;
        
    } else {
        self.actionDrawerHeightConstraint.constant = 0;
        _actionDrawerBorderLayer.hidden = YES;
        
        self.labelHorizontalInsetConstraint.constant = (20 * (self.comment.indentation + 1));
        self.headerStackHorizontalInsetConstraint.constant = (20 * (self.comment.indentation + 1));
    }
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (void)didTapBackgroundView:(id)sender {
    NSLog(@"CommentCell, didTapBackgroundView:");
    
    self.comment.collapsed = !_comment.collapsed;
}

- (void)commentCollapsedChanged:(NSNotification*)notification {
    Comment * comment = notification.object;
    
    if([comment.commentId isEqual: self.comment.commentId]) {
        
        if(self.comment.collapsed) {
            [self collapseCell];
        } else {
            [self uncollapseCell];
        }
    }
}

- (void)collapseCell {
    
//    NSLog(@"collapseCell");
    
//    self.commentLabel.hidden = YES;
    self.commentTextView.hidden = YES;
    
    [self.contentView removeConstraint:_stackViewLabelJoinConstraint];
    [self.contentView removeConstraint:_drawerBottomConstraint];
    [self.contentView removeConstraint:_labelDrawerJoinConstraint];
    
    [self.contentView addConstraint:_headerViewBottomConstraint];
    
    self.headerUpDownLabel.text = kHeaderDownIcon;
    self.headerUpDownLabel.textColor = [UIColor grayColor];
    self.authorLabel.textColor = [UIColor grayColor];
    
    if(self.comment.parentComment) {
        _headerViewHeightConstraint.constant = 0;
        _headerView.hidden = YES;
        _actionDrawerBorderLayer.hidden = YES;
        _headerBorderLayer.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)uncollapseCell {

//    NSLog(@"uncollapseCell");
    
//    self.commentLabel.hidden = NO;
    self.commentTextView.hidden = NO;
    
    if(self.comment.parentComment) {
        _headerViewHeightConstraint.constant = 20;
        _headerView.hidden = NO;
        _actionDrawerBorderLayer.hidden = NO;
        _headerBorderLayer.hidden = NO;
    }
    
    [self.contentView removeConstraint:_headerViewBottomConstraint];
    
    [self.contentView addConstraint:_stackViewLabelJoinConstraint];
    [self.contentView addConstraint:_drawerBottomConstraint];
    [self.contentView addConstraint:_labelDrawerJoinConstraint];
    
    self.headerUpDownLabel.text = kHeaderUpIcon;
    self.headerUpDownLabel.textColor = [UIColor orangeColor];
    self.authorLabel.textColor = [UIColor orangeColor];
    
    [self setNeedsUpdateConstraints];
}

#pragma mark -StoryActionDrawerViewDelegate Methods
- (void)actionDrawerView:(ActionDrawerView*)view
    didTapActionWithType:(NSNumber*)type {
    
    if([self.delegate respondsToSelector:@selector(commentCell:didTapActionWithType:)]) {
        [self.delegate performSelector:@selector(commentCell:didTapActionWithType:)
                            withObject:self withObject:type];
    }
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSLog(@"textView:shouldInteractWithURL:inRange:");
    
    if([self.delegate respondsToSelector:@selector(commentCell:didTapLink:)]) {
        [self.delegate performSelector:@selector(commentCell:didTapLink:)
                            withObject:self withObject:URL];
    }
    
    return NO;
}


//- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldSetLineFragmentRect:(inout CGRect *)lineFragmentRect lineFragmentUsedRect:(inout CGRect *)lineFragmentUsedRect baselineOffset:(inout CGFloat *)baselineOffset inTextContainer:(NSTextContainer *)textContainer forGlyphRange:(NSRange)glyphRange {
//    
//    if(_blockQuoteRanges) {
////        NSLog(@"_blockQuoteRanges: %@", _blockQuoteRanges);
//        
//        for(NSArray * rangeArray in _blockQuoteRanges) {
//            NSRange blockQuoteRange = NSMakeRange([[rangeArray firstObject] integerValue], [[rangeArray lastObject] integerValue]);
//            NSRange intersection = NSIntersectionRange(glyphRange, blockQuoteRange);
//            if(intersection.length > 0) {
////                NSLog(@"found intersection, lineFragmentRect: %@, lineFragmentUsedRect: %@, baselineOffset: %f", NSStringFromCGRect(*lineFragmentRect), NSStringFromCGRect(*lineFragmentUsedRect), *baselineOffset);
//                
//                
////                *lineFragmentUsedRect = CGRectMake((*lineFragmentUsedRect).origin.x + 20.0f, (*lineFragmentUsedRect).origin.y, (*lineFragmentUsedRect).size.width - 20.0f, (*lineFragmentUsedRect).size.height);
////                *lineFragmentRect = CGRectMake((*lineFragmentRect).origin.x + 20.0f, (*lineFragmentRect).origin.y, (*lineFragmentRect).size.width - 20.0f, (*lineFragmentRect).size.height);
//            }
//        }
//        
//        return YES;
//    }
////    NSLog(@"shouldSetLineFragmentRect, %@, layoutManager.textStorage substringWithRange: %@", NSStringFromRange(glyphRange), [[layoutManager.textStorage string] substringWithRange:glyphRange]);    
//    
//    return NO;
//}

@end
