//
//  DAContextMenuTableViewController.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAContextMenuTableViewController.h"

#import "DAOverlayView.h"


@interface DAContextMenuTableViewController () <DAOverlayViewDelegate>

@property (strong, nonatomic) DAContextMenuCell *cellDisplayingMenuOptions;
@property (strong, nonatomic) DAOverlayView *overlayView;

@end


@implementation DAContextMenuTableViewController

#pragma mark - Private

- (void)hideMenuOptionsAnimated:(BOOL)animated
{
    [self.cellDisplayingMenuOptions setMenuOptionsViewHidden:YES animated:animated];
    self.cellDisplayingMenuOptions = nil;
    [self.overlayView removeFromSuperview];
}

#pragma mark * DAContextMenuCell delegate

- (BOOL)shouldShowMenuOptionsViewInCell:(DAContextMenuCell *)cell
{
    BOOL result = (self.cellDisplayingMenuOptions == nil);
    [self hideMenuOptionsAnimated:YES];
    return result;
}

- (void)contextMenuDidShowInCell:(DAContextMenuCell *)cell
{
    self.cellDisplayingMenuOptions = cell;
    if (!_overlayView) {
        _overlayView = [[DAOverlayView alloc] initWithFrame:self.view.bounds];
        _overlayView.backgroundColor = [UIColor clearColor];
        _overlayView.delegate = self;
    }
    self.overlayView.hidden = NO;
    self.overlayView.frame = self.view.bounds;
    [self.view addSubview:_overlayView];
}

- (void)contextMenuCellDidSelectMoreOption:(DAContextMenuCell *)cell
{
    NSAssert(NO, @"Should be implemented in subclasses");
}

#pragma mark * DAOverlayView delegate

- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL shouldIterceptTouches = YES;
    CGPoint location = [self.view convertPoint:point fromView:view];
    CGRect rect = [self.view convertRect:self.cellDisplayingMenuOptions.frame toView:self.view];
    shouldIterceptTouches = CGRectContainsPoint(rect, location);
    if (!shouldIterceptTouches) {
        [self hideMenuOptionsAnimated:YES];
    }
    return (shouldIterceptTouches) ? [self.cellDisplayingMenuOptions hitTest:point withEvent:event] : view;
}

#pragma mark  * UITableView delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath] == self.cellDisplayingMenuOptions) {
        [self hideMenuOptionsAnimated:YES];
        return NO;
    }
    return YES;
}

@end