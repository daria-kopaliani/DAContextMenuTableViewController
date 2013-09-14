//
//  DAСontextMenuCell.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/24/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAContextMenuCell.h"

@interface DAContextMenuCell () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *contextMenuView;
@property (assign, nonatomic, getter = isContextMenuHidden) BOOL contextMenuHidden;
@property (assign, nonatomic) BOOL shouldDisplayContextMenuView;
@property (assign, nonatomic) CGFloat initialTouchPositionX;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

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
    self.contextMenuView.backgroundColor = self.contentView.backgroundColor;
    [self.contentView insertSubview:self.contextMenuView belowSubview:self.actualContentView];
    
    [self setUpDefaultButtons];
    
    self.contextMenuHidden = self.contextMenuView.hidden = YES;
    self.shouldDisplayContextMenuView = NO;
    self.menuOptionsAnimationDuration = 0.3;
    self.bounceValue = 30.;
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panRecognizer.delegate = self;
    self.contextMenuEnabled = YES;
    [self addGestureRecognizer:self.panRecognizer];
    [self setNeedsLayout];
}

- (void)setUpDefaultButtons
{
    self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 80., CGRectGetHeight(self.actualContentView.bounds))];
    [self.actionButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.actionButton setBackgroundColor:[UIColor colorWithRed:255./255. green:59./255. blue:48./255. alpha:1.]];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contextMenuView addSubview:self.actionButton];

    self.moreActionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 80., CGRectGetHeight(self.actualContentView.bounds))];
    [self.moreActionsButton setTitle:@"More" forState:UIControlStateNormal];
    [self.moreActionsButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.moreActionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contextMenuView addSubview:self.moreActionsButton];
}

#pragma mark - Public

- (CGFloat)contextMenuWidth
{
    return CGRectGetWidth(self.actionButton.frame) + CGRectGetWidth(self.moreActionsButton.frame);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contextMenuView.frame = self.actualContentView.bounds;
    [self.contentView sendSubviewToBack:self.contextMenuView];
    [self.contentView bringSubviewToFront:self.actualContentView];
    
    CGFloat height = floorf(CGRectGetHeight(self.actualContentView.bounds));
    CGFloat width = floorf(CGRectGetWidth(self.actualContentView.bounds));
    self.moreActionsButton.frame = CGRectMake(width - CGRectGetWidth(self.actionButton.frame) - CGRectGetWidth(self.moreActionsButton.frame), 0., CGRectGetWidth(self.moreActionsButton.frame), height);
    self.actionButton.frame = CGRectMake(width - CGRectGetWidth(self.actionButton.frame), 0., CGRectGetWidth(self.actionButton.frame), height);
}

#pragma mark * Overwitten setters

- (void)setActionButton:(UIButton *)actionButton
{
    _actionButton = actionButton;
    [self.contextMenuView addSubview:actionButton];
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        self.contextMenuView.hidden = YES;
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)setMoreActionsButton:(UIButton *)moreActionsButton
{
    _moreActionsButton = moreActionsButton;
    [self.contextMenuView addSubview:moreActionsButton];
    [self setNeedsLayout];
}

- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler
{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    if (!hidden) {
        self.contextMenuView.hidden = hidden;
    }
    CGRect frame = CGRectMake((hidden) ? 0 : -[self contextMenuWidth], 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [UIView animateWithDuration:(animated) ? self.menuOptionsAnimationDuration : 0.
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.actualContentView.frame = frame;
     } completion:^(BOOL finished) {
         self.contextMenuHidden = hidden;
         self.shouldDisplayContextMenuView = !hidden;
         if (!hidden) {
             [self.delegate contextMenuDidShowInCell:self];
         } else {
             [self.delegate contextMenuDidHideInCell:self];
         }
         if (completionHandler) {
             completionHandler();
         }
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        self.contextMenuView.hidden = YES;
        [super setSelected:selected animated:animated];
    }
}

- (void)setContextMenuEnabled:(BOOL)contextMenuEnabled
{
    _contextMenuEnabled = contextMenuEnabled;
    self.panRecognizer.enabled = contextMenuEnabled;
    if (contextMenuEnabled) {
        self.actualContentView.backgroundColor = self.backgroundColor;
        [self.contentView insertSubview:self.contextMenuView belowSubview:self.actualContentView];
    } else {
        self.actualContentView.backgroundColor = [UIColor clearColor];
        [self.contextMenuView removeFromSuperview];
    }
}

#pragma mark - Private

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    if (self.contextMenuEnabled) {
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self layoutSubviews];
            self.actualContentView.backgroundColor = self.backgroundColor;
            UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
            
            CGPoint currentTouchPoint = [panRecognizer locationInView:self.contentView];
            CGFloat currentTouchPositionX = currentTouchPoint.x;
            CGPoint velocity = [recognizer velocityInView:self.contentView];
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                self.initialTouchPositionX = currentTouchPositionX;
                if (velocity.x > 0) {
                    [self.delegate contextMenuWillHideInCell:self];
                } else {
                    [self.delegate contextMenuDidShowInCell:self];
                }
            } else if (recognizer.state == UIGestureRecognizerStateChanged) {
                CGPoint velocity = [recognizer velocityInView:self.contentView];
                if (!self.contextMenuHidden || (velocity.x > 0. || [self.delegate shouldShowMenuOptionsViewInCell:self])) {
                    if (self.selected) {
                        [self setSelected:NO animated:NO];
                    }
                    self.contextMenuView.hidden = NO;
                    CGFloat panAmount = currentTouchPositionX - self.initialTouchPositionX;
                    self.initialTouchPositionX = currentTouchPositionX;
                    CGFloat minOriginX = -[self contextMenuWidth] - self.bounceValue;
                    CGFloat maxOriginX = 0.;
                    CGFloat originX = CGRectGetMinX(self.actualContentView.frame) + panAmount;
                    originX = MIN(maxOriginX, originX);
                    originX = MAX(minOriginX, originX);
                    
                    
                    if ((originX < -0.5 * [self contextMenuWidth] && velocity.x < 0.) || velocity.x < -100) {
                        self.shouldDisplayContextMenuView = YES;
                    } else if ((originX > -0.3 * [self contextMenuWidth] && velocity.x > 0.) || velocity.x > 100) {
                        self.shouldDisplayContextMenuView = NO;
                    }
                    self.actualContentView.frame = CGRectMake(originX, 0., CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
                }
            } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
                [self setMenuOptionsViewHidden:!self.shouldDisplayContextMenuView animated:YES completionHandler:nil];
            }
        }
    }
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

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setMenuOptionsViewHidden:YES animated:NO completionHandler:nil];
}

#pragma mark * UIPanGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.contextMenuEnabled) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
            return fabs(translation.x) > fabs(translation.y);
        }
        return YES;
    } else {
        return NO;
    }
}

@end