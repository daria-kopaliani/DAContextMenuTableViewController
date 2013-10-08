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
@property (assign, nonatomic) BOOL didPerformContextMenuLayout;
@property (assign, nonatomic) CGFloat initialTouchPositionX;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (strong, nonatomic) NSLayoutConstraint *actualContentViewTrailingSpaceConstraint;

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
    
    // configuring defaults
    self.actualContentView.backgroundColor = self.backgroundColor;
    self.contextMenuHidden = YES;
    self.shouldDisplayContextMenuView = NO;
    self.menuOptionsAnimationDuration = 0.3;
    self.bounceValue = 30.;
    self.contextMenuEnabled = YES;
    
    [self setUpContstraints];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panRecognizer.delegate = self;
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

#pragma mark * Overwitten setters

- (void)setContextMenuBackgroundColor:(UIColor *)contextMenuBackgroundColor
{
    _contextMenuBackgroundColor = contextMenuBackgroundColor;
    if (_contextMenuView) {
        self.contextMenuView.backgroundColor = contextMenuBackgroundColor;
    }
}

- (void)setContextMenuEnabled:(BOOL)contextMenuEnabled
{
    _contextMenuEnabled = contextMenuEnabled;
    self.panRecognizer.enabled = contextMenuEnabled;
    if (contextMenuEnabled) {
        self.actualContentView.backgroundColor = self.backgroundColor;
    } else {
        self.actualContentView.backgroundColor = [UIColor clearColor];
        [self.contextMenuButtons removeAllObjects];
        [self.contextMenuView removeFromSuperview];
        self.contextMenuView = nil;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        _contextMenuView.hidden = YES;
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
    self.actualContentViewTrailingSpaceConstraint.constant = (hidden) ? 0 : -[self contextMenuWidth];
    [UIView animateWithDuration:(animated) ? self.menuOptionsAnimationDuration : 0.
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         [self.contentView layoutIfNeeded];
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
        _contextMenuView.hidden = YES;
        [super setSelected:selected animated:animated];
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
                self.contextMenuView.hidden = NO;
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
                    CGFloat contextMenuWidth = [self contextMenuWidth];
                    CGFloat panAmount = currentTouchPositionX - self.initialTouchPositionX;
                    self.initialTouchPositionX = currentTouchPositionX;
                    CGFloat indent = self.actualContentViewTrailingSpaceConstraint.constant + panAmount;
                    indent = MIN(0., indent);
                    indent = MAX(-contextMenuWidth - self.bounceValue, indent);
                    
                    CGFloat velocityToTriggerAnimation = 100.;
                    if ((indent < -0.5 * contextMenuWidth && velocity.x < 0.) || velocity.x < -velocityToTriggerAnimation) {
                        self.shouldDisplayContextMenuView = YES;
                    } else if ((indent > -0.3 * contextMenuWidth && velocity.x > 0.) || velocity.x > velocityToTriggerAnimation) {
                        self.shouldDisplayContextMenuView = NO;
                    }
                    self.actualContentViewTrailingSpaceConstraint.constant = indent;
                }
            } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
                [self setMenuOptionsViewHidden:!self.shouldDisplayContextMenuView animated:YES completionHandler:nil];
            }
        }
    }
}

- (void)layoutContextMenuView
{
    if (self.dataSource && self.contextMenuEnabled && !self.didPerformContextMenuLayout) {
        NSLog(@"layoutContextMenuView");
        self.didPerformContextMenuLayout = YES;
        NSUInteger buttonsCount = [self.dataSource numberOfButtonsInContextMenuCell:self];
        [self.contextMenuButtons removeAllObjects];
        for (NSInteger i = buttonsCount - 1; i >= 0; i--) {
            UIButton *button = [self.dataSource contextMenuCell:self buttonAtIndex:i];
            NSAssert(button, @"Context menu cell could not get button at index %d in %p", i, __PRETTY_FUNCTION__);
            [self.contextMenuView addSubview:button];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button addTarget:self action:@selector(contextMenuButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            NSDictionary *views = @{@"button" : button};
            [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"[button(==%lf)]", CGRectGetWidth(button.frame)] options:0 metrics:nil views:views]];
            [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[button(==%lf)]", CGRectGetHeight(button.frame)] options:0 metrics:nil views:views]];
            
            switch ([self.dataSource contextMenuCell:self alignmentForButtonAtIndex:i]) {
                case DAContextMenuCellButtonVerticalAlignmentModeTop: {
                    [self.contextMenuView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]" options:0 metrics:nil views:views]];
                } break;
                case DAContextMenuCellButtonVerticalAlignmentModeCenter: {
                    [self.contextMenuView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                                     attribute:NSLayoutAttributeCenterY
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.contextMenuView
                                                                                     attribute:NSLayoutAttributeCenterY
                                                                                    multiplier:1. constant:0.]];
                } break;
                case DAContextMenuCellButtonVerticalAlignmentModeBottom: {
                    [self.contextMenuView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button]|" options:0 metrics:nil views:views]];
                } break;
            }
            if (self.contextMenuButtons.count) {
                UIButton *anotherButton = [self.contextMenuButtons firstObject];
                NSAssert(anotherButton, nil);
                [self.contextMenuView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:anotherButton
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                multiplier:1. constant:0.]];
            } else {
                [self.contextMenuView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[button]|" options:0 metrics:nil views:views]];
            }
            [self.contextMenuButtons insertObject:button atIndex:0];
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.contextMenuView removeFromSuperview];
    self.contextMenuView = nil;
    [self.contextMenuButtons removeAllObjects];
    self.didPerformContextMenuLayout = NO;
    [self setMenuOptionsViewHidden:YES animated:NO completionHandler:nil];
}

- (void)setUpContstraints
{
    [self.contentView removeConstraints:self.contentView.constraints];
    self.actualContentViewTrailingSpaceConstraint = [NSLayoutConstraint constraintWithItem:_actualContentView
                                                                                 attribute:NSLayoutAttributeRight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.contentView
                                                                                 attribute:NSLayoutAttributeRight
                                                                                multiplier:1. constant:0.];
    [self.contentView addConstraint:self.actualContentViewTrailingSpaceConstraint];
    NSAssert(self.actualContentView && self.contentView, @"ActualContentView & contentView should be initializad by this point %p", __PRETTY_FUNCTION__);
    NSDictionary *views = @{@"actualContentView" : self.actualContentView, @"superView" : self.contentView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[actualContentView(==superView)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[actualContentView]|" options:0 metrics:nil views:views]];
    [self.contentView updateConstraints];
}

#pragma mark * Lazy getters

- (UIView *)contextMenuView
{
    if (!_contextMenuView) {
        _contextMenuView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _contextMenuView.backgroundColor = (self.contextMenuBackgroundColor) ? self.contextMenuBackgroundColor : self.backgroundColor;
        [self.contentView insertSubview:_contextMenuView belowSubview:self.actualContentView];
        _contextMenuView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{@"contextMenuView" : _contextMenuView};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contextMenuView]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contextMenuView]|" options:0 metrics:nil views:views]];
    }
    return _contextMenuView;
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