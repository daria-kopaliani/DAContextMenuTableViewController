//
//  DAViewController.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAViewController.h"

#import "DAContextMenuCell.h"
#import "DADemoCell.h"


@interface DAViewController () <DAContextMenuCellDataSource, DAContextMenuCellDelegate>

@property (assign, nonatomic) NSInteger rowsCount;

@end


@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"DAContextMenuTableViewController";
    self.rowsCount = 20;
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
    cell.dataSource = self;
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.;
}

#pragma mark * DAContextMenuCell data source

- (NSUInteger)numberOfButtonsInContextMenuCell:(DAContextMenuCell *)cell
{
    return 2;
}

- (UIButton *)contextMenuCell:(DAContextMenuCell *)cell buttonAtIndex:(NSUInteger)index
{
    DADemoCell *demoCell = [cell isKindOfClass:[DADemoCell class]] ? (DADemoCell *)cell : nil;
    switch (index) {
        case 0: return demoCell.moreButton;
        case 1: return demoCell.archiveButton;
        default: return nil;
    }
}

- (DAContextMenuCellButtonVerticalAlignmentMode)contextMenuCell:(DAContextMenuCell *)cell alignmentForButtonAtIndex:(NSUInteger)index
{
    return DAContextMenuCellButtonVerticalAlignmentModeCenter;
}

- (CGFloat)contextMenuCell:(DAContextMenuCell *)cell heightForButtonAtIndex:(NSUInteger)index
{
    return 95.;
}

- (CGFloat)contextMenuCell:(DAContextMenuCell *)cell widthForButtonAtIndex:(NSUInteger)index
{
    return 90.;
}

#pragma mark * DAContextMenuCell delegate

- (void)contextMenuCell:(DAContextMenuCell *)cell buttonTappedAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0: {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Reply", @"Forward", @"Flag", @"Mark as Unread", @"Move to Junk", @"Move Message...",  nil];
            [actionSheet showInView:self.view];
        } break;
        case 1: {
            if ([self.tableView indexPathForCell:cell]) {
                self.rowsCount -= 1;
                [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
            }
        } break;
        default: break;
            
    }
}

@end