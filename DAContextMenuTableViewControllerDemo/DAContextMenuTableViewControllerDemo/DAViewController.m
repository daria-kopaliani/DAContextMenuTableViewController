//
//  DAViewController.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAViewController.h"

#import "DAContextMenuCell.h"


@interface DAViewController () <DAContextMenuCellDataSource, DAContextMenuCellDelegate>

@property (assign, nonatomic) NSInteger rowsCount;

@end


@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"DAContextMenuTableViewController";
    self.rowsCount = 20;
//    self.tableView.allowsSelection = NO;
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
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 80., 80.)];
    button.titleLabel.numberOfLines = 2;
    [button setTitle:@"Add to\nPlaylist" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    UIButton *button = nil;
    switch (index) {
        case 0: {
            button = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 100., 40.)];
            [button setBackgroundColor:[UIColor redColor]];
        } break;
        case 1: {
            button = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 100., 80.)];
            [button setBackgroundColor:[UIColor greenColor]];
        } break;
            
        default:break;
    }
    return button;
}

- (DAContextMenuCellButtonVerticalAlignmentMode)contextMenuCell:(DAContextMenuCell *)cell alignmentForButtonAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0: {
            return DAContextMenuCellButtonVerticalAlignmentModeBottom;
        } break;
        case 1: {
            return DAContextMenuCellButtonVerticalAlignmentModeBottom;
        } break;
        default: return DAContextMenuCellButtonVerticalAlignmentModeCenter;
    }
}
#pragma mark * DAContextMenuCell delegate

- (void)actionButtonTappedInContextMenuCell:(DAContextMenuCell *)cell
{
    self.rowsCount -= 1;
    [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)moreActionsButtonTappedInContextMenuCell:(DAContextMenuCell *)cell
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Reply", @"Forward", @"Flag", @"Mark as Unread", @"Move to Junk", @"Move Message...",  nil];
    [actionSheet showInView:self.view];
}

@end
