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
    self.contextMenuView = [[UIView alloc] initWithFrame:self.actualContentView.bounds];
    self.contextMenuView.backgroundColor = [UIColor clearColor];
    [self.contentView insertSubview:self.contextMenuView belowSubview:self.actualContentView];
    self.backgroundColor = [UIColor whiteColor];
    self.contextMenuHidden = self.contextMenuView.hidden = YES;
    self.editable = YES;
    self.moreOptionsButtonTitle = @"More";
    self.deleteButtonTitle = @"Delete";
    [self addGestureRecognizers];
    [self setNeedsLayout];
}

#pragma mark - Public

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contextMenuView.frame = self.actualContentView.bounds;
    [self.contentView sendSubviewToBack:self.contextMenuView];
    [self.contentView bringSubviewToFront:self.actualContentView];
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat menuOptionButtonWidth = [self menuOptionButtonWidth];
    self.moreOptionsButton.frame = CGRectMake(width - 2 * menuOptionButtonWidth, 0., menuOptionButtonWidth, height);
    self.deleteButton.frame = CGRectMake(width - menuOptionButtonWidth, 0., menuOptionButtonWidth, height);
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

- (CGFloat)menuOptionButtonWidth
{
    NSString *string = ([self.deleteButtonTitle length] > [self.moreOptionsButtonTitle length]) ? self.deleteButtonTitle : self.moreOptionsButtonTitle;
    CGFloat offset = 15.;
    CGFloat width = [string sizeWithFont:self.moreOptionsButton.titleLabel.font].width + 2 * offset;
    if (width > 90.) {
        width = 90.;
    }
    return width;
}

- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    self.deleteButton.userInteractionEnabled = self.moreOptionsButton.userInteractionEnabled = NO;
    if (hidden != self.isContextMenuHidden) {
        self.contextMenuHidden = hidden;
        if (!hidden) {
            self.contextMenuView.hidden = NO;
        }
        CGFloat contextMenuWidth = CGRectGetWidth(self.moreOptionsButton.frame) + CGRectGetWidth(self.deleteButton.frame);
        [UIView animateWithDuration:(animated) ? 0.3 : 0. animations:^{
            CGRect frame = self.actualContentView.frame;
            frame.origin.x = (hidden) ? 0. : -contextMenuWidth;
            self.actualContentView.frame = frame;
        } completion:^(BOOL finished) {
            self.actualContentView.userInteractionEnabled = hidden;
            self.contextMenuView.hidden = hidden;
            if (!hidden) {
                self.deleteButton.userInteractionEnabled = self.moreOptionsButton .userInteractionEnabled = YES;
                [self.delegate contextMenuDidShowInCell:self];
            }
        }];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        [super setSelected:selected animated:animated];
    }
}

#pragma mark - Private

- (void)addGestureRecognizers
{
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(showMenuOptionsView)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipeRecognizer];
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(hideMenuOptionsView)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipeRecognizer];
}

- (void)deleteButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(contextMenuCellDidSelectDeleteOption:)]) {
        [self.delegate contextMenuCellDidSelectDeleteOption:self];
    }
}

- (void)moreButtonTapped
{
    [self.delegate contextMenuCellDidSelectMoreOption:self];
}

- (void)hideMenuOptionsView
{
    [self setMenuOptionsViewHidden:YES animated:YES];
}

- (void)showMenuOptionsView
{
    if ([self.delegate shouldShowMenuOptionsViewInCell:self]) {
        [self setMenuOptionsViewHidden:NO animated:YES];
    }
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