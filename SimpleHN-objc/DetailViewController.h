//
//  DetailViewController.h
//  SimpleHN-objc
//
//  Created by James Eunson on 26/09/2015.
//  Copyright © 2015 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Firebase.h"
#import "FirebaseUI.h"
#import "CommentCell.h"
#import "Story.h"

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CommentCellDelegate>

@property (strong, nonatomic) Story * detailItem;
@property (nonatomic, strong) UITableView * tableView;

//@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;

@end

