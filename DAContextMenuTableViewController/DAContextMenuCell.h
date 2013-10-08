//
//  DAСontextMenuCell.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DAContextMenuCellButtonVerticalAlignmentModeCenter = 0,
    DAContextMenuCellButtonVerticalAlignmentModeTop,
    DAContextMenuCellButtonVerticalAlignmentModeBottom
} DAContextMenuCellButtonVerticalAlignmentMode;

@class DAContextMenuCell;

@protocol DAContextMenuCellDataSource <NSObject>

- (NSUInteger)numberOfButtonsInContextMenuCell:(DAContextMenuCell *)cell;
- (UIButton *)contextMenuCell:(DAContextMenuCell *)cell buttonAtIndex:(NSUInteger)index;
- (DAContextMenuCellButtonVerticalAlignmentMode)contextMenuCell:(DAContextMenuCell *)cell alignmentForButtonAtIndex:(NSUInteger)index;

@end


@protocol DAContextMenuCellDelegate <NSObject>

- (void)actionButtonTappedInContextMenuCell:(DAContextMenuCell *)cell;
- (void)moreActionsButtonTappedInContextMenuCell:(DAContextMenuCell *)cell;
- (void)contextMenuDidHideInCell:(DAContextMenuCell *)cell;
- (void)contextMenuDidShowInCell:(DAContextMenuCell *)cell;
- (void)contextMenuWillHideInCell:(DAContextMenuCell *)cell;
- (void)contextMenuWillShowInCell:(DAContextMenuCell *)cell;
- (BOOL)shouldShowMenuOptionsViewInCell:(DAContextMenuCell *)cell;

@end


@interface DAContextMenuCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *actualContentView;

@property (readonly, assign, nonatomic, getter = isContextMenuHidden) BOOL contextMenuHidden;
@property (assign, nonatomic) BOOL contextMenuEnabled;
@property (assign, nonatomic) CGFloat menuOptionsAnimationDuration;
@property (assign, nonatomic) CGFloat bounceValue;
@property (readonly, strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

@property (weak, nonatomic) id<DAContextMenuCellDataSource> dataSource;
@property (weak, nonatomic) id<DAContextMenuCellDelegate> delegate;

- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler;

@end
