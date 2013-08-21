//
//  DAContextMenuTableViewController.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAContextMenuCell.h"

@interface DAContextMenuTableViewController : UITableViewController <DAContextMenuCellDelegate>

@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;

@end
