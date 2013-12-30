	#import "DAContextMenuViewController.h"

@interface DAContextMenuViewController () <DAOverlayViewDelegate>

@property (strong, nonatomic) DAContextMenuCell *cellDisplayingMenuOptions;
@property (strong, nonatomic) DAOverlayView *overlayView;
@property (assign, nonatomic) BOOL customEditing;
@property (assign, nonatomic) BOOL customEditingAnimationInProgress;
@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;

@end


@implementation DAContextMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCustomEditing:NO];
    [self setCustomEditingAnimationInProgress:NO];
//    self.customEditing = self.customEditingAnimationInProgress = NO;
}

#pragma mark - Public

- (void)hideMenuOptionsAnimated:(BOOL)animated
{
    __block DAContextMenuViewController *weakSelf = self;
    [self.cellDisplayingMenuOptions setMenuOptionsViewHidden:YES animated:animated completionHandler:^{
        weakSelf.customEditing = NO;
    }];
}

#pragma mark - Private

- (void)setCustomEditing:(BOOL)customEditing
{
    if (_customEditing != customEditing) {
        _customEditing = customEditing;
        self.tableView.scrollEnabled = !customEditing;
        if (customEditing) {
            if (!_overlayView) {
                _overlayView = [[DAOverlayView alloc] initWithFrame:self.tableView.frame];
                _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                _overlayView.backgroundColor = [UIColor clearColor];
                 _overlayView.delegate = self;
            }
            self.overlayView.frame = self.view.bounds;
            [self.view addSubview:_overlayView];
            if (self.shouldDisableUserInteractionWhileEditing) {
                for (UIView *view in self.tableView.subviews) {
                    if ((view.gestureRecognizers.count == 0) && view != self.cellDisplayingMenuOptions && view != self.overlayView) {
                        view.userInteractionEnabled = NO;
                    }
                }
            }
        } else {
            self.cellDisplayingMenuOptions = nil;
            [self.overlayView removeFromSuperview];
            for (UIView *view in self.tableView.subviews) {
                if ((view.gestureRecognizers.count == 0) && view != self.cellDisplayingMenuOptions && view != self.overlayView) {
                    view.userInteractionEnabled = YES;
                }
            }
        }
    }
}

- (void)contextMenuCell:(DAContextMenuCell *)cell buttonTappedAtIndex:(NSUInteger)index
{
    NSAssert(NO, @"%s should be implemented in subclasses", __PRETTY_FUNCTION__);
}

- (void)contextMenuDidHideInCell:(DAContextMenuCell *)cell
{
    self.customEditing = NO;
    self.customEditingAnimationInProgress = NO;
}

- (void)contextMenuDidShowInCell:(DAContextMenuCell *)cell
{
    self.customEditingAnimationInProgress = YES;
}

- (void)contextMenuWillHideInCell:(DAContextMenuCell *)cell
{
    self.customEditingAnimationInProgress = YES;
}

- (void)contextMenuWillShowInCell:(DAContextMenuCell *)cell
{
    self.cellDisplayingMenuOptions = cell;
    self.customEditing = YES;
    self.customEditingAnimationInProgress = NO;
}

- (BOOL)shouldDisplayContextMenuViewInCell:(DAContextMenuCell *)cell
{
    return self.customEditing && !self.customEditingAnimationInProgress;
}

#pragma mark * DAOverlayView delegate

- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self.tableView convertRect:self.cellDisplayingMenuOptions.frame toView:self.tableView];
    CGPoint rectpoint = [self.tableView convertPoint:point fromView:view];
    
    BOOL shouldIterceptTouches = CGRectContainsPoint(rect,rectpoint);
    if (!shouldIterceptTouches) {
        [self hideMenuOptionsAnimated:YES];
    }
    return (shouldIterceptTouches) ? [self.cellDisplayingMenuOptions hitTest:point withEvent:event] : view;
}

#pragma mark * UITableView delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath] == self.cellDisplayingMenuOptions) {
        [self hideMenuOptionsAnimated:YES];
        return NO;
    }
    return YES;
}

@end