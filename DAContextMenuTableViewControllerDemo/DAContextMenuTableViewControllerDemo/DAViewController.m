//
//  DAViewController.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAViewController.h"

#import "DAContextMenuCell.h"


@interface DAViewController ()

@property (assign, nonatomic) NSInteger rowsCount;

@end


@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rowsCount = 20;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.1) {
        CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
        self.tableView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0., 0., 0.);
    }
    self.tableView.allowsSelection = NO;
}

#pragma mark - Private

- (void)setRowsCount:(NSInteger)rowsCount
{
    if (rowsCount < 0) {
        _rowsCount = 0;
    } else {
        _rowsCount = rowsCount;
    }
}

#pragma mark * Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DAContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.;
}

#pragma mark * DAContextMenuCell delegate

- (void)contextMenuCellDidSelectDeleteOption:(DAContextMenuCell *)cell
{
    self.rowsCount -= 1;
    [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)contextMenuCellDidSelectMoreOption:(DAContextMenuCell *)cell
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Reply", @"Forward", @"Flag", @"Mark as Unread", @"Move to Junk", @"Move Message...",  nil];
    [actionSheet showInView:self.view];
}

@end
