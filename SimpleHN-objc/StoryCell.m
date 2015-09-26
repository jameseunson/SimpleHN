//
//  StoryCell.m
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import "StoryCell.h"
#import "NSDate+TimeAgo.h"

@implementation StoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Property Override Methods
- (void)setStory:(Story *)story {
    _story = story;
    
    self.textLabel.text = story.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %@ · %@",
                                 story.url.host, story.author, story.time];
    
    UIStackView *accessoryView = [[UIStackView alloc] init];
    
    accessoryView.axis = UILayoutConstraintAxisVertical;
    accessoryView.distribution = UIStackViewDistributionEqualSpacing;
    accessoryView.alignment = UIStackViewAlignmentCenter;
    accessoryView.spacing = 30;
    accessoryView.translatesAutoresizingMaskIntoConstraints = false;
    
    UIButton * accessoryButton = [[UIButton alloc] init];
    [accessoryButton setTitle:[NSString stringWithFormat:@"%lu", [story.kids count]] forState:UIControlStateNormal];
    accessoryButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [accessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    accessoryButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    accessoryButton.layer.borderWidth = 1.0f;
    accessoryButton.layer.cornerRadius = 4.0f;
    
    [accessoryButton sizeToFit];
    
    [accessoryView addArrangedSubview:accessoryButton];
    
    UILabel * scoreLabel = [[UILabel alloc] init];
    scoreLabel.text = [story.score stringValue];
    scoreLabel.font = [UIFont systemFontOfSize:11.0f];
    scoreLabel.textColor = [UIColor orangeColor];
    [scoreLabel sizeToFit];
    
    [accessoryView addArrangedSubview:scoreLabel];
    
//    self.accessoryView = accessoryView;

    [self.contentView addSubview:accessoryView];
    
    [self.contentView invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(accessoryView, accessoryButton, scoreLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[accessoryView(44)]" options:0 metrics:nil views:bindings]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accessoryView(44)]-10-|" options:0 metrics:nil views:bindings]];
}

@end
