//
//  DAСontextMenuCell.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAContextMenuCell.h"

@interface DAContextMenuCell ()

@property (strong, nonatomic) UIView *contextMenuView;
@property (strong, nonatomic) UIButton *moreOptionsButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIView *actualContentView;
@property (assign, nonatomic, getter = isContextMenuHidden) BOOL contextMenuHidden;

@end


@implementation DAContextMenuCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp
{
    self.actualContentView = [[UIView alloc] initWithFrame:self.bounds];
    [self.actualContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.actualContentView];
    
    self.contextMenuView = [[UIView alloc] initWithFrame:self.bounds];
    self.contextMenuView.backgroundColor = [UIColor clearColor];
    [self.contentView insertSubview:self.contextMenuView belowSubview:self.actualContentView];
    self.backgroundColor = [UIColor whiteColor];
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleSwipe)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeRecognizer];
    self.contextMenuHidden = YES;
    self.editable = YES;
    self.moreOptionsButtonTitle = @"More";
    self.deleteButtonTitle = @"Delete";
    [self setNeedsLayout];
    [self setMenuOptionsViewHidden:YES animated:NO];
}

#pragma mark - Public

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *view in self.contentView.subviews) {
        if (view != self.actualContentView && view != self.contextMenuView) {
            [self.actualContentView addSubview:view];
        }
    }
    
    self.actualContentView.frame = self.bounds;
    CGFloat offset = 10.;
    CGFloat moreOptionsButtonWidth = [self.moreOptionsButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.moreOptionsButton.titleLabel.font}].width + 2. * offset;
    CGFloat deleteButtonWidth = [self.deleteButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.deleteButton.titleLabel.font}].width + 2. * offset;
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    self.moreOptionsButton.frame = CGRectMake(width - moreOptionsButtonWidth - deleteButtonWidth, 0., moreOptionsButtonWidth, height);
    self.deleteButton.frame = CGRectMake(width - deleteButtonWidth, 0., deleteButtonWidth, height);
}

- (void)setDeleteButtonTitle:(NSString *)deleteButtonTitle
{
    _deleteButtonTitle = deleteButtonTitle;
    [self.deleteButton setTitle:deleteButtonTitle forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setMoreOptionsButtonTitle:(NSString *)moreOptionsButtonTitle
{
    _moreOptionsButtonTitle = moreOptionsButtonTitle;
    [self.moreOptionsButton setTitle:self.moreOptionsButtonTitle forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    self.deleteButton.userInteractionEnabled = self.moreOptionsButton.userInteractionEnabled = NO;
    if (hidden != self.isContextMenuHidden) {
        self.contextMenuHidden = hidden;
        CGFloat contextMenuWidth = CGRectGetWidth(self.moreOptionsButton.frame) + CGRectGetWidth(self.deleteButton.frame);
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.actualContentView.frame;
            frame.origin.x = (hidden) ? 0. : -contextMenuWidth;
            self.actualContentView.frame = frame;
        } completion:^(BOOL finished) {
            self.actualContentView.userInteractionEnabled = hidden;
            if (!hidden) {
                if (hidden) {
                    [self.moreOptionsButton removeFromSuperview];
                }
                self.moreOptionsButton.alpha = (float)(!hidden);
                self.contextMenuView.hidden = self.deleteButton.hidden = hidden;
                self.deleteButton.userInteractionEnabled = self.moreOptionsButton .userInteractionEnabled = YES;
                [self.delegate contextMenuDidShowInCell:self];
            }
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
//    self.contextMenuView.hidden
}
#pragma mark - Private

- (void)deleteButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(contextMenuCellDidSelectDeleteOption:)]) {
        [self.delegate contextMenuCellDidSelectDeleteOption:self];
    }
}

- (void)handleSwipe
{
    if ([self.delegate shouldShowMenuOptionsViewInCell:self]) {
        [self setMenuOptionsViewHidden:NO animated:YES];
    }
}

- (void)moreButtonTapped
{
    [self.delegate contextMenuCellDidSelectMoreOption:self];
}

#pragma mark * Lazy getters

- (UIButton *)moreOptionsButton
{
    if (!_moreOptionsButton) {
        CGRect frame = CGRectMake(0., 0., 100., CGRectGetHeight(self.actualContentView.frame));
        _moreOptionsButton = [[UIButton alloc] initWithFrame:frame];
        _moreOptionsButton.backgroundColor = [UIColor lightGrayColor];
        [self.contextMenuView addSubview:_moreOptionsButton];
        [_moreOptionsButton addTarget:self action:@selector(moreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreOptionsButton;
}

- (UIButton *)deleteButton
{
    if (self.editable) {
        if (!_deleteButton) {
            CGRect frame = CGRectMake(0., 0., 100., CGRectGetHeight(self.actualContentView.frame));
            _deleteButton = [[UIButton alloc] initWithFrame:frame];
            _deleteButton.backgroundColor = [UIColor colorWithRed:251./255. green:34./255. blue:38./255. alpha:1.];
            [self.contextMenuView addSubview:_deleteButton];
            [_deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        }
        return _deleteButton;
    }
    return nil;
}

@end