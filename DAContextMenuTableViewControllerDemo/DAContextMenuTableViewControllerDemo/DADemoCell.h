//
//  DADemoCell.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 10/8/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAContextMenuCell.h"


@interface DADemoCell : DAContextMenuCell

@property (strong, nonatomic) IBOutlet UIButton *archiveButton;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;

@end