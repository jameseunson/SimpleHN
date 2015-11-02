//
//  CommentCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 2/11/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "CommentCell.h"
#import "TimeAgoInWords-Swift.h"

#define kHeaderDownIcon @"▼"
#define kHeaderUpIcon @"▲"

@interface CommentCell ()

@property (nonatomic, strong) NSLayoutConstraint * headerStackHorizontalInsetConstraint;
@property (nonatomic, strong) NSLayoutConstraint * labelHorizontalInsetConstraint;

@end

@implementation CommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.indentationWidth = 20.0f;
        
        self.commentLabel = [[KILabel alloc] init];
        self.commentLabel.backgroundColor = [UIColor clearColor];
        
        self.commentLabel.font = [UIFont systemFontOfSize:14.0f];
        self.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.userInteractionEnabled = YES;
        
        self.commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.commentLabel.automaticLinkDetectionEnabled = YES;
        
        [self.contentView addSubview:_commentLabel];
        
        self.headerStackView = [[UIStackView alloc] init];
        _headerStackView.axis = UILayoutConstraintAxisHorizontal;
        _headerStackView.alignment = UIStackViewAlignmentCenter;
        _headerStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.headerUpDownLabel = [[UILabel alloc] init];
        
        _headerUpDownLabel.text = kHeaderUpIcon;
        _headerUpDownLabel.font = [UIFont systemFontOfSize:12.0f];
        _headerUpDownLabel.backgroundColor = [UIColor clearColor];
        _headerUpDownLabel.textColor = [UIColor grayColor];
        
        [_headerStackView addArrangedSubview:_headerUpDownLabel];
        
        self.authorLabel = [[UILabel alloc] init];
        
        _authorLabel.font = [UIFont systemFontOfSize:12.0f];
        _authorLabel.textColor = [UIColor grayColor];
        _authorLabel.backgroundColor = [UIColor clearColor];
        
        [_headerStackView addArrangedSubview:_authorLabel];
        
        self.dateLabel = [[UILabel alloc] init];
        
        _dateLabel.font = [UIFont systemFontOfSize:12.0f];
        _dateLabel.textColor = [UIColor grayColor];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        
        [_headerStackView addArrangedSubview:_dateLabel];

        [self.contentView addSubview:_headerStackView];
        
        self.headerBorderLayer = [CALayer layer];
        _headerBorderLayer.backgroundColor = [RGBCOLOR(215, 215, 215) CGColor];
        [self.layer insertSublayer:_headerBorderLayer atIndex:100];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_commentLabel, _headerStackView);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                          @"V:|-[_headerStackView]-10-[_commentLabel]-|" options:0 metrics:nil views:bindings]];
        
        NSArray * stackViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:
                                                   @"H:|-20-[_headerStackView]-|" options:0 metrics:nil views:bindings];
        for(NSLayoutConstraint * constraint in stackViewHorizontalConstraints) {
            if(constraint.constant == 20) {
                self.headerStackHorizontalInsetConstraint = constraint;
            }
        }
        [self.contentView addConstraints:stackViewHorizontalConstraints];
        
        NSArray * labelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:
                                      @"H:|-20-[_commentLabel]-|" options:0 metrics:nil views:bindings];
        
        for(NSLayoutConstraint * constraint in labelHorizontalConstraints) {
            if(constraint.constant == 20) {
                self.labelHorizontalInsetConstraint = constraint;
            }
        }
        [self.contentView addConstraints:labelHorizontalConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightForBorder = (1.0 / [UIScreen mainScreen].scale);
    
//    _headerBorderLayer.frame = CGRectMake(_headerStackView.frame.origin.x, _headerStackView.frame.origin.y +
//                                          _headerStackView.frame.size.height + 4.0f,
//                                          _headerStackView.frame.size.width, heightForBorder);
    _headerBorderLayer.frame = CGRectMake(0, _headerStackView.frame.origin.y +
                                          _headerStackView.frame.size.height + 4.0f,
                                          self.frame.size.width, heightForBorder);
}

#pragma mark - Property Override Methods
- (void)setComment:(Comment *)comment {
    _comment = comment;
    
    NSArray * links = comment.links;
    
    if(comment.text) {
        self.commentLabel.text = comment.text;
        
        // Handle URL presses by sending delegate call to enclosing controller
        __block CommentCell * blockSelf = self;
        self.commentLabel.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
            if([blockSelf.delegate respondsToSelector:@selector(commentCell:didTapLink:)]) {
                
                NSLog(@"urlLinkTapHandler: %@, %lu", string, range.location);
                
                for(CommentLink * link in links) {
                    if(link.start == range.location) {
                        [blockSelf.delegate performSelector:@selector(commentCell:didTapLink:)
                                                 withObject:blockSelf withObject:link];
                        break;
                    }
                }
            }
        };
    }

    self.labelHorizontalInsetConstraint.constant = (20 * (comment.indentation + 1));
    self.headerStackHorizontalInsetConstraint.constant = (20 * (comment.indentation + 1));
    
    self.authorLabel.text = comment.author;
    self.dateLabel.text = [comment.time timeAgoInWords];
    
    [self setNeedsLayout];
}

@end
