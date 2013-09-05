//
//  DAContextMenuTableViewController.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAContextMenuCell.h"
#import "DAOverlayView.h"


@interface DAContextMenuTableViewController : UITableViewController <DAContextMenuCellDelegate, DAOverlayViewDelegate>

@property (readonly, strong, nonatomic) DAContextMenuCell *cellDisplayingMenuOptions;
@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;

- (void)hideMenuOptionsAnimated:(BOOL)animated;

@end
