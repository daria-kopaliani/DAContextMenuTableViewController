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
@property (strong, nonatomic) NSMutableArray *contextMenuButtons;
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
    self.contextMenuButtons = [NSMutableArray array];
    self.contextMenuView = [[UIView alloc] initWithFrame:self.actualContentView.bounds];
    [self.contentView insertSubview:self.contextMenuView belowSubview:self.actualContentView];
    self.actualContentView.backgroundColor = self.backgroundColor;
    
    self.contextMenuHidden = self.contextMenuView.hidden = YES;
    self.shouldDisplayContextMenuView = NO;
    self.menuOptionsAnimationDuration = 0.3;
    self.bounceValue = 30.;
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panRecognizer.delegate = self;
    self.contextMenuEnabled = YES;
    [self addGestureRecognizer:self.panRecognizer];
}

#pragma mark - Public

- (CGFloat)contextMenuWidth
{
    CGFloat width = 0.;
    if (self.dataSource) {
        for (NSUInteger i = 0; i < [self.dataSource numberOfButtonsInContextMenuCell:self]; i++) {
            UIButton *button = [self.dataSource contextMenuCell:self buttonAtIndex:i];
            width += CGRectGetWidth(button.frame);
        }
    }

    return width;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.contextMenuHidden) {
        [self layoutContextMenuView];
    }
}

#pragma mark * Overwitten getters

- (UIColor *)contextMenuBackgroundColor
{
    return self.contentView.backgroundColor;
}

#pragma mark * Overwitten setters

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        self.contextMenuView.hidden = YES;
        [super setHighlighted:highlighted animated:animated];
    }
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

- (void)setContextMenuBackgroundColor:(UIColor *)contextMenuBackgroundColor
{
    self.contentView.backgroundColor = contextMenuBackgroundColor;
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

- (void)contextMenuButtonDidClick:(UIButton *)sender
{
    NSUInteger index = [self.contextMenuButtons indexOfObject:sender];
    if (index != NSNotFound) {
        [self.delegate contextMenuCell:self buttonTappedAtIndex:index];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    if (self.contextMenuEnabled) {
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
            CGPoint currentTouchPoint = [panRecognizer locationInView:self.contentView];
            CGFloat currentTouchPositionX = currentTouchPoint.x;
            CGPoint velocity = [recognizer velocityInView:self.contentView];
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                [self layoutContextMenuView];
                self.initialTouchPositionX = currentTouchPositionX;
                if (velocity.x > 0) {
                    [self.delegate contextMenuWillHideInCell:self];
                } else {
                    [self.delegate contextMenuDidShowInCell:self];
                }
            } else if (recognizer.state == UIGestureRecognizerStateChanged) {
                CGPoint velocity = [recognizer velocityInView:self.contentView];
                if (!self.contextMenuHidden || (velocity.x > 0. || [self.delegate shouldDisplayContextMenuViewInCell:self])) {
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

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setMenuOptionsViewHidden:YES animated:NO completionHandler:nil];
}

- (void)layoutContextMenuView
{
    NSLog(@"layoutContextMenuView");
    if (self.dataSource) {
        self.contextMenuView.frame = self.actualContentView.bounds;
        [self.contentView sendSubviewToBack:self.contextMenuView];
        [self.contentView bringSubviewToFront:self.actualContentView];
        
        NSUInteger buttonsCount = [self.dataSource numberOfButtonsInContextMenuCell:self];
        CGFloat trailingSpace = 0.;
        CGFloat cellWidth = CGRectGetWidth(self.contentView.frame);
        CGFloat cellHeight = CGRectGetHeight(self.contentView.frame);
        [self.contextMenuButtons removeAllObjects];
        for (NSInteger i = buttonsCount - 1; i >= 0; i--) {
            UIButton *button = [self.dataSource contextMenuCell:self buttonAtIndex:i];
            [button addTarget:self action:@selector(contextMenuButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat buttonWidth = CGRectGetWidth(button.frame);
            CGFloat buttonHeight = CGRectGetHeight(button.frame);
            NSAssert(button, @"Context menu cell could not get button at index %d", i);
            CGFloat y;
            switch ([self.dataSource contextMenuCell:self alignmentForButtonAtIndex:i]) {
                case DAContextMenuCellButtonVerticalAlignmentModeTop: {
                    y = 0;
                } break;
                case DAContextMenuCellButtonVerticalAlignmentModeCenter: {
                    y = roundf(cellHeight - buttonHeight) / 2.;
                }
                case DAContextMenuCellButtonVerticalAlignmentModeBottom: {
                    y = cellHeight - buttonHeight;
                }
            }
            button.frame = CGRectMake(cellWidth - buttonWidth - trailingSpace, y, buttonWidth, buttonHeight);
            trailingSpace += buttonWidth;
            [self.contextMenuView addSubview:button];
            [self.contextMenuButtons insertObject:button atIndex:0];
        }
    }
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