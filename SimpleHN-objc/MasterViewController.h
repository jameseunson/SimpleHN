//
//  MasterViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firebase.h"
#import "StoryCell.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UIScrollViewDelegate, StoryCellDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@end

