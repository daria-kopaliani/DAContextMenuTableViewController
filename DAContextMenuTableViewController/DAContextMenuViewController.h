//
//  DAContextMenuViewController.h
//  ExchangeDefender Mobile
//
//  Created by Travis Sheldon on 12/27/13.
//  Copyright (c) 2013 ExchangeDefender. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAContextMenuCell.h"
#import "DAOverlayView.h"

@interface DAContextMenuViewController : UIViewController <DAContextMenuCellDelegate, DAOverlayViewDelegate>

@property (readonly, strong, nonatomic) DAContextMenuCell *cellDisplayingMenuOptions;
@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;
@property(strong, nonatomic) IBOutlet UITableView *tableView;
- (void)hideMenuOptionsAnimated:(BOOL)animated;

@end
